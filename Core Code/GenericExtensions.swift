//
//  GenericExtensions.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
/// Change this variable to false in order to stop the Uber SDK from printing things to the console
public var uberLogMode = true

/**
A generic printer for non-nil data that gets printed to the console.

:param: item The item to print.
*/
internal func uberLog<T>(item: T)
{
	if uberLogMode
	{
		println("> Uber API Log:\t \(item)\n")
	}
}
/**
A generic printer for nil data. It will only get printed to the console if the data passed in is non-nil.

:param: item The optional data to print.
*/
internal func uberLog<T>(item: T?)
{
	if let item = item where uberLogMode
	{
		println("Uber API Log: \(item)\n")
	}
	
}

/**
Use this enumeration to provide the scopes you wish to show the user when performing OAuth2 with the Uber API.

- Profile:     The Profile scope grants you access to basic profile information on a user's Uber account including their first name, email address, and profile picture
- HistoryLite: The HistroyLite scope enables you to pull trip data including times and product type of a user's historical pickups and drop-offs.
- Request:     The Request scope grants you permission to make requests for Uber Products on behalf of users.
*/
@objc public enum UberScopes : Int, Any, Printable, DebugPrintable
{
	/// The Profile scope grants you access to basic profile information on a user's Uber account including their first name, email address, and profile picture
	case Profile
	/// The HistroyLite scope enables you to pull trip data including times and product type of a user's historical pickups and drop-offs.
	case HistoryLite
	/// The Request scope grants you permission to make requests for Uber Products on behalf of users.
	case Request
	
	public var description : String
	{
		get
		{
			switch self
			{
			case .Profile:
				return "profile"
			case .HistoryLite:
				return "history_lite"
			case .Request:
				return "request"
			default:
				assert(false, "We should never reach here since we only support scopes defined within this enum.")
				return ""
			}
		}
	}
	public var debugDescription : String  { get { return description } }
}

/**
This is an enumeration that allows you to choose between the ProductionAPI and the SandboxAPI.
*/
@objc public enum UberBaseURL : Int, Printable, DebugPrintable
{
	/// Use ProductionAPI when you want the SDK to communicate with the actual production API provided by Uber.
	case ProductionAPI
	/// Use the SandboxAPI when you want the SDK to communicate with the sandbox API provided by Uber for testing purposes.
	case SandboxAPI
	internal var URL:  String
		{
		get
		{
			switch self
			{
			case .ProductionAPI:
				return "https://api.uber.com"
			case .SandboxAPI:
				return "https://sandbox-api.uber.com"
			default:
				assert(false, "You must choose between either the ProductionAPI or the SandboxAPI")
				return ""
			}
		}
	}
	public var description : String {
		get
		{
			switch self
			{
			case .ProductionAPI:
				return "Production API"
			case .SandboxAPI:
				return "Sandbox API"
			default:
				assert(false, "You must choose between either the Production API or the Sandbox API")
				return ""
			}
		}
	}
	public var debugDescription : String { get { return description } }
}


internal var sharedDelegate : UberManagerDelegate!
internal var sharedUserManager : UberUserOAuth!

internal enum HTTPMethod : String
{
	case Post = "POST"
	case Get = "GET"
	case Delete = "DELETE"
	case Put = "PUT"
}

internal protocol JSONCreateable
{
	init?(JSON: [NSObject : AnyObject])
}
internal protocol UberObjectHasImage
{
	var imageURL : NSURL? { get }
}

public typealias UberSuccessBlock = () -> Void
public typealias UberErrorHandler =  (UberError?, NSURLResponse?, NSError?) -> Void


internal func createRequestForURL(var URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get) -> NSURLRequest
{
	URL = "\(sharedDelegate.baseURL.URL)\(URL)"
	if let pathParameters = paths
	{
		URL += "?"
		for pathParameter in pathParameters
		{
			URL += "\(pathParameter.0)=\(pathParameter.1)&"
		}
		URL = URL.substringToIndex(URL.endIndex.predecessor())
	}
	let mutableRequest = NSMutableURLRequest(URL: NSURL(string: URL)!)
	mutableRequest.HTTPMethod = method.rawValue
	mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
	// If we couldn't add the user access header
	if !sharedUserManager.addBearerAccessHeader(mutableRequest)
	{
		if accessTokenRequired
		{
			assert(false, "You must call the ... in the Uber Manager class to ensure that the user has been authorized before using this end point because it requires an OAuth2 access token.")
		}
		else
		{
			mutableRequest.addValue("Token \(sharedDelegate.serverToken)", forHTTPHeaderField: "Authorization")
		}
	}
	if let queryParameters = queries
	{
		let data = NSJSONSerialization.dataWithJSONObject(queryParameters, options: nil, error: nil)!
		let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
		mutableRequest.HTTPBody = NSJSONSerialization.dataWithJSONObject(queryParameters, options: nil, error: nil)
	}
	return mutableRequest.copy() as! NSURLRequest
}

private func performRequest(request: NSURLRequest, success: ([NSObject: AnyObject]) -> Void, failure: UberErrorHandler?)
{
	let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
	let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
		if (error == nil)
		{
			var JSONError : NSError?
			if let JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? [NSObject: AnyObject]
			{
				success(JSONData)
			}
			else
			{
				uberLog("Error parsing JSON.")
				failure?(UberError(JSONData: data), response, JSONError)
			}
		}
		else
		{
			failure?(UberError(JSONData: data), response, error)
		}
	})
	task.resume()
}

internal func fetchObjects<T: JSONCreateable>(URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get, arrayKey key: String, completionHandler success: ([T], [NSObject: AnyObject]) -> Void, errorHandler failure: UberErrorHandler?)
{
	let request = createRequestForURL(URL, withQueryParameters: queries, withPathParameters: paths, requireUserAccessToken: accessTokenRequired, usingHTTPMethod: method)
	performRequest(request, {(JSON) in
		if let arrayJSON = JSON[key] as? [[NSObject : AnyObject]]
		{
			let objects = arrayJSON.map { T(JSON: $0) }.filter { $0 != nil }.map { $0! }
			success(objects, JSON)
		}
		else
		{
			uberLog("No values found inside of JSON object. Please look at the console to figure out what went wrong.")
			uberLog(JSON)
			failure?(UberError(JSON: JSON), nil, NSError())
		}
	}, failure)
}

internal func fetchObject<T: JSONCreateable>(var URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get, completionHandler success: (T) -> Void, errorHandler failure: UberErrorHandler?)
{
	let request = createRequestForURL(URL, withQueryParameters: queries, withPathParameters: paths, requireUserAccessToken: accessTokenRequired, usingHTTPMethod: method)
	performRequest(request, {(JSON) in
		if let object = T(JSON: JSON)
		{
			success(object)
		}
		else
		{
			uberLog("Could not create object using JSON. Please look at the console to figure out what went wrong.")
			uberLog(JSON)
			failure?(UberError(JSON: JSON), nil, NSError())
		}
	}, failure)
}