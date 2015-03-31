//
//  UberManager.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

public typealias UberErrorHandler =  (NSURLResponse!, NSError!) -> Void
/**
This is an enumeration that allows you to choose between the ProductionAPI and the SandboxAPI.
*/
@objc public enum UberBaseURL : Int, Printable, DebugPrintable
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
You must implement this protocol to communicate with the UberManager and return information as and when requested. This information can all be found in the Uber app dashboard at `https://developer.uber.com/apps/`.
*/
@objc public protocol UberManagerDelegate
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
}

/**
This class is the main wrapper around the über API. Create a instance of this class to communicate with this SDK and make all your main requests using this wrapper.
*/
public class UberManager : NSObject
{
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
	
	public func synchronouslyGetProducts(#latitude: Float, longitude: Float, errorHandler: UberErrorHandler) -> [UberProduct]?
	{
		let request = createRequestForURL("\(delegate.baseURL.URL)/v1/products", withQueryParameters: ["latitude" : latitude, "longitude" : longitude])
		var response : NSURLResponse?
		var error : NSError?
		
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
		var JSONData: NSDictionary? = nil
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
		}
		if (error == nil)
		{
			if let productsJSON = JSONData?.objectForKey("products") as? [NSDictionary]
			{
				for product in productsJSON
				{
					
				}
			}
		}
		else
		{
			uberLog(JSONData)
			errorHandler(response, error)
		}
		return nil
	}
	public func asynchronouslyGetProducts(#latitude: Float, longitude: Float, completionBlock success: UberProductSuccessBlock, errorHandler: UberErrorHandler)
	{
		
	}
}
extension UberManager
{
	private func createRequestForURL(var URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, andPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get) -> NSURLRequest
	{
		if let pathParameters = paths
		{
			URL += "?"
			for pathParameter in pathParameters
			{
				URL += "\(pathParameter.0):\(pathParameter.1)&"
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
				request.addValue(delegate.serverToken, forHTTPHeaderField: "server_token")
			}
		}
		if let queryParameters = queries
		{
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