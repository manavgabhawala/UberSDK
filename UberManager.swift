//
//  UberManager.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import CoreLocation

public typealias UberErrorHandler =  (NSURLResponse!, NSError!) -> Void

/**
This is an enumeration that allows you to choose between the ProductionAPI and the SandboxAPI.
*/
public enum UberBaseURL : Printable, DebugPrintable
{
	/// Use ProductionAPI when you want the SDK to communicate with the actual production API provided by Uber.
	case ProductionAPI
	/// Use the SandboxAPI when you want the SDK to communicate with the sandbox API provided by Uber for testing purposes.
	case SandboxAPI
	private var URL:  String
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
				assert(false, "You must choose between either the ProductionAPI or the SandboxAPI")
				return ""
			}
		}
	}
	public var debugDescription : String { get { return description } }
}
/**
Use this enumeration to provide the scopes you wish to show the user when performing OAuth2 with the Uber API.

- Profile:     The Profile scope grants you access to basic profile information on a user's Uber account including their first name, email address, and profile picture
- HistoryLite: The HistroyLite scope enables you to pull trip data including times and product type of a user's historical pickups and drop-offs.
- Request:     The Request scope grants you permission to make requests for Uber Products on behalf of users.
*/
public enum UberScopes : Printable, DebugPrintable
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
You must implement this protocol to communicate with the UberManager and return information as and when requested. This information can all be found in the Uber app dashboard at `https://developer.uber.com/apps/`.
*/
public protocol UberManagerDelegate
{
	/// The application name with which you setup the Uber app.
	var applicationName: String { get }
	/// The client ID for the application setup in Uber
	var clientID : String { get }
	/// The client secret for the application setup in Uber
	var clientSecret: String { get }
	/// The server token for the application setup in Uber
	var serverToken : String { get }
	/// The redirect URI/URL for the application setup in Uber
	var redirectURI : String { get }
	/// This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	var baseURL : UberBaseURL { get }
	var scopes : [UberScopes] { get }
}

/**
This class is the main wrapper around the über API. Create a instance of this class to communicate with this SDK and make all your main requests using this wrapper.
*/
public class UberManager : NSObject
{
	//MARK: - General Initializers and Properties
	private var delegate : UberManagerDelegate
	private var userManager : UberUserOAuth
	
	/**
	Dedicated default constructor for an UberManager.
	
	:param: delegate The delegate which implements the UberManagerDelegate protocol and returns all the important details required for the Manager to perform API operations on your application's behalf.
	
	:returns: An initialized UberManager wrapper.
	*/
	public init(delegate: UberManagerDelegate)
	{
		self.delegate = delegate
		userManager = UberUserOAuth(delegate: delegate)
	}
	
	//MARK: - Product Fetching
	public func synchronouslyFetchProducts(#location: CLLocation, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberProduct]?
	{
		return synchronouslyFetchProducts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, response: response, error: error)
	}
	public func synchronouslyFetchProducts(#latitude: Double, longitude: Double, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberProduct]?
	{
		let request = createRequestForURL("\(delegate.baseURL.URL)/v1/products", withPathParameters: ["latitude" : latitude, "longitude" : longitude])
		
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: error)
		var JSONData: NSDictionary? = nil
		var JSONError : NSError?
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
		}
		if (error.memory == nil)
		{
			if let productsJSON = JSONData?.objectForKey("products") as? [[NSObject : AnyObject]]
			{
				let products = productsJSON.map { UberProduct(JSON: $0) }
				let actualProducts = products.filter { $0 != nil }.map { $0! }
				uberLog("Number of products found: \(actualProducts.count)")
				return actualProducts
			}
			uberLog("Error parsing Product JSON. Please look at the console to see the JSON that got parsed.")
			uberLog(JSONError)
		}
		else
		{
			uberLog(JSONData)
			
		}
		return nil
	}
	public func asynchronouslyFetchProducts(#location: CLLocation, completionBlock success: UberProductSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		asynchronouslyFetchProducts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
	public func asynchronouslyFetchProducts(#latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL("\(delegate.baseURL.URL)/v1/products", withPathParameters: ["latitude": latitude, "longitude": longitude])
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			var JSONError: NSError?
			if (error == nil)
			{
				if let JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
				{
					if let productsJSON = JSONData.objectForKey("products") as? [[NSObject: AnyObject]]
					{
						let products = productsJSON.map { UberProduct(JSON: $0) }
						let actualProducts = products.filter { $0 != nil }.map { $0! }
						uberLog("Number of products found: \(actualProducts.count)")
						success?(actualProducts)
						return
					}
					uberLog("No products found inside of JSON object. Please look at the console to figure out what went wrong.")
					uberLog(JSONError)
					failure?(response, error)
				}
				else
				{
					uberLog("Error parsing Product JSON. Please look at the console to see the JSON that got parsed.")
					uberLog(JSONError)
					failure?(response, error)
				}
			}
			else
			{
				failure?(response, error)
			}
		})
	}
}
extension UberManager
{
	private func createRequestForURL(var URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get) -> NSURLRequest
	{
		if let pathParameters = paths
		{
			URL += "?"
			for pathParameter in pathParameters
			{
				URL += "\(pathParameter.0)=\(pathParameter.1)&"
			}
			URL = URL.substringToIndex(URL.endIndex.predecessor())
		}
		let request = NSMutableURLRequest(URL: NSURL(string: URL)!)
		request.HTTPMethod = method.rawValue
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		// If we couldn't add the user access header
		if !userManager.addBearerAccessHeader(request)
		{
			if accessTokenRequired
			{
				userManager.setupOAuth2AccountStore()
				// TODO: User related stuff.
			}
			else
			{
				request.addValue("Token \(delegate.serverToken)", forHTTPHeaderField: "Authorization")
			}
		}
		if let queryParameters = queries
		{
			let data = NSJSONSerialization.dataWithJSONObject(queryParameters, options: nil, error: nil)!
			let json = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
			println(json)
			request.HTTPBody = NSJSONSerialization.dataWithJSONObject(queryParameters, options: nil, error: nil)
		}
		return request.copy() as! NSURLRequest
	}
}

private enum HTTPMethod : String
{
	case Post = "POST"
	case Get = "GET"
	case Delete = "DELETE"
	case Put = "PUT"
}