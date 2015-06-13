//
//  UberManager.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/11/15.
//
//

import Foundation
import CoreLocation
import CoreGraphics

internal protocol Viewable
{
	func addSubview(subview: Self)
	var frame: CGRect { get }
}

/**
You must implement this protocol to communicate with the UberManager and return information as and when requested. This information can all be found in the Uber app dashboard at `https://developer.uber.com/apps/`.
*/
@objc public protocol UberManagerDelegate
{
	/// The application name with which you setup the Uber app.
	@objc var applicationName: String { get }
	/// The client ID for the application setup in Uber
	@objc var clientID : String { get }
	/// The client secret for the application setup in Uber
	@objc var clientSecret: String { get }
	/// The server token for the application setup in Uber
	@objc var serverToken : String { get }
	/// The redirect URI/URL for the application setup in Uber
	@objc var redirectURI : String { get }
	/// This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	@objc var baseURL : UberBaseURL { get }
	/// Return an array of raw values of the scopes enum that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, return an empty array. This must be an array of UberScopes. See the enum type.
	@objc var scopes : [Int] { get }
}

/**
*  This is the main class to which you make calls to access the UberAPI.
*/
@objc public class UberManager
{
	//MARK: - General Initializers and Properties
	
	private let delegate : UberManagerDelegate
	internal let userAuthenticator : UberUserAuthenticator
	
	/**
	Set this property to define the language that the Uber SDK should respond in. The default value of this property is English.
	*/
	public var language : Language = .English
	
	/**
	Dedicated default constructor for an UberManager.
	
	- parameter delegate: The delegate which implements the UberManagerDelegate protocol and returns all the important details required for the Manager to perform API operations on your application's behalf.
	
	returns: An initialized UberManager wrapper.
	*/
	@objc public init(delegate: UberManagerDelegate)
	{
		self.delegate = delegate
		self.userAuthenticator = UberUserAuthenticator(clientID: delegate.clientID, clientSecret: delegate.clientSecret, redirectURI: delegate.redirectURI, scopes: delegate.scopes.map { UberScopes(rawValue: $0)! } )
	}
	
	/**
	Use this constructor if you do not wish to create a delegate around one of your classes and just wish to pass in the data once.
	
	- parameter applicationName: The application name with which you setup the Uber app.
	- parameter clientID:        The client ID for the application setup in Uber
	- parameter clientSecret:    The client secret for the application setup in Uber
	- parameter serverToken:     The server token for the application setup in Uber
	- parameter redirectURI:     The redirect URI/URL for the application setup in Uber
	- parameter baseURL:         This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	- parameter scopes:          Return an array of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, return an empty array. This must be an array of UberScopes. See the enum type.
	
	- returns: An initialized UberManager wrapper.
	*/
	public convenience init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes])
	{
		self.init(delegate: PrivateUberDelegate(applicationName: applicationName, clientID: clientID, clientSecret: clientSecret, serverToken: serverToken, redirectURI: redirectURI, baseURL: baseURL, scopes: scopes))
	}
	
	/**
	Use this constructor if you do not wish to create a delegate around one of your classes and just wish to pass in the data once. Only use this method if you are using Objective C. Otherwise use the other initializer to ensure for type safety.
	
	- parameter applicationName: The application name with which you setup the Uber app.
	- parameter clientID:        The client ID for the application setup in Uber
	- parameter clientSecret:    The client secret for the application setup in Uber
	- parameter serverToken:     The server token for the application setup in Uber
	- parameter redirectURI:     The redirect URI/URL for the application setup in Uber
	- parameter baseURL:         This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	- parameter scopes:          Return an array of raw values of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, return an empty array. This must be an array of UberScopes. See the enum type.
	
	- returns: An initialized UberManager wrapper.
	*/
	@objc public convenience init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [Int])
	{
		self.init(delegate: PrivateUberDelegate(applicationName: applicationName, clientID: clientID, clientSecret: clientSecret, serverToken: serverToken, redirectURI: redirectURI, baseURL: baseURL, scopes: scopes.map { UberScopes(rawValue: $0)!} ))
	}
	
	
	/**
	Use this function to log an Uber user out of the system and remove all associated cached files about the user.
	
	- parameter completionBlock: The block of code to execute once we have successfully logged a user out.
	- parameter errorHandler:    An error occurred while loggin the user out. Handle the error in this block.
	*/
	@objc public func logUberUserOut(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		userAuthenticator.logout(completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Product Fetching
extension UberManager
{
	/**
	Use this function to fetch uber products for a particular latitude and longitude `asynchronously`.
	
	- parameter latitude:  		The latitude for which you want to find Uber products.
	- parameter longitude: 		The longitude for which you want to find Uber products.
	
	- parameter completionBlock: The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	
	- parameter errorHandler:   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	@objc public func fetchProductsForLocation(latitude latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/products", withPathParameters: ["latitude": latitude, "longitude": longitude], arrayKey: "products", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	/**
	Use this function to fetch uber products for a particular location `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	- parameter location: 		The location for which you want to find Uber products.
	
	- parameter completionBlock: The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	
	- parameter errorHandler:  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	@objc public func fetchProductsForLocation(location: CLLocation, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchProductsForLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
	
	/**
	Use this function to communicate with the Uber Product Endpoint. You can create an `UberProduct` wrapper using just the productID.
	
	- parameter productID: The productID with which to create a new `UberProduct`
	- parameter success:   The block of code to execute if we successfully create the `UberProduct`
	- parameter failure:   The block of code to execute if an error occurs.
	
	*:warning:* Product IDs are different for different regions. Fetch all products for a location using the `UberManager` instance.
	*/
	@objc public class func createProduct(productID: String, success: (UberProduct) -> Void, errorHandler failure: UberErrorHandler?)
	{
		//fetchObject("/v1/products/\(productID)", completionHandler: success, errorHandler: failure)
	}
}

//MARK: - Price Estimates
extension UberManager
{
	/**
	Use this function to fetch price estimates for a particular trip between two points as defined by you `asynchronously`.
	
	- parameter startLatitude:  	The starting latitude for the trip.
	- parameter startLongitude: 	The starting longitude for the trip.
	- parameter endLatitude:    	The ending latitude for the trip.
	- parameter endLongitude:   	The ending longitude for the trip.
	
	- parameter completionBlock: The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	
	- parameter errorHandler:   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	@objc public func fetchPriceEstimateForTrip(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/estimates/price", withPathParameters: ["start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude], arrayKey: "prices", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	/**
	Use this function to fetch price estimates for a particular trip between two points `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.
	
	- parameter startLocation: 	The starting location for the trip
	- parameter endLocation:   	The ending location for the trip
	
	- parameter completionBlock: The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	
	- parameter errorHandler:  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	@objc public func fetchPriceEstimateForTrip(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchPriceEstimateForTrip(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}


// MARK: Generic Helpers
extension UberManager
{
	@objc private class PrivateUberDelegate : UberManagerDelegate
	{
		@objc let applicationName : String
		@objc let clientID : String
		@objc let clientSecret: String
		@objc let serverToken : String
		@objc let redirectURI : String
		@objc let baseURL : UberBaseURL
		@objc let scopes : [Int]
		
		init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes])
		{
			self.applicationName = applicationName
			self.clientID = clientID
			self.clientSecret = clientSecret
			self.serverToken = serverToken
			self.redirectURI = redirectURI
			self.baseURL = baseURL
			self.scopes = scopes.map { $0.rawValue }
		}
	}
	
	private func createRequestForURL(var URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get) -> NSURLRequest
	{
		URL = "\(delegate.baseURL.URL)\(URL)"
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
		if !userAuthenticator.addBearerAccessHeader(mutableRequest)
		{
			if accessTokenRequired
			{
				fatalError("You must call the performUserAuthorization in the Uber Manager class to ensure that the user has been authorized before using this end point because it requires an OAuth2 access token.")
			}
			else
			{
				mutableRequest.addValue("Token \(delegate.serverToken)", forHTTPHeaderField: "Authorization")
			}
		}
		mutableRequest.addValue(language.description, forHTTPHeaderField: "Accept-Language")
		if let queryParameters = queries
		{
			do
			{
				mutableRequest.HTTPBody = try NSJSONSerialization.dataWithJSONObject(queryParameters, options: [])
			}
			catch
			{
				mutableRequest.HTTPBody = nil
			}
		}
		return mutableRequest.copy() as! NSURLRequest
	}
	
	private func performRequest(request: NSURLRequest, success: ([NSObject: AnyObject], NSURLResponse?) -> Void, failure: UberErrorHandler?)
	{
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			guard error == nil else { failure?(UberError(JSONData: data, response: response) ?? UberError(error: error!, response: response)); return }
			do
			{
				guard let JSONData = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as? [NSObject: AnyObject]
					else { failure?(UberError(JSONData: data, response: response) ?? UberError(error: error!, response: response)); return }
				success(JSONData, response)
			}
			catch let error as NSError
			{
				failure?(UberError(error: error, response: response))
			}
			catch
			{
				failure?(UberError(JSONData: data, response: response))
			}
		})
		task?.resume()
	}
	
	private func fetchObjects<T: JSONCreateable>(URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get, arrayKey key: String, completionHandler success: ([T], [NSObject: AnyObject]) -> Void, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL(URL, withQueryParameters: queries, withPathParameters: paths, requireUserAccessToken: accessTokenRequired, usingHTTPMethod: method)
		performRequest(request, success: {(JSON, response) in
			if let arrayJSON = JSON[key] as? [[NSObject : AnyObject]]
			{
				let objects = arrayJSON.map { T(JSON: $0) }.filter { $0 != nil }.map { $0! }
				success(objects, JSON)
			}
			else
			{
				failure?(UberError(JSON: JSON, response: response))
			}
		}, failure: failure)
	}
	
	private func fetchObject<T: JSONCreateable>(URL: String, withQueryParameters queries: [NSObject: AnyObject]? = nil, withPathParameters paths: [NSObject: AnyObject]? = nil, requireUserAccessToken accessTokenRequired: Bool = false, usingHTTPMethod method: HTTPMethod = .Get, completionHandler success: (T) -> Void, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL(URL, withQueryParameters: queries, withPathParameters: paths, requireUserAccessToken: accessTokenRequired, usingHTTPMethod: method)
		performRequest(request, success: {(JSON, response) in
			if let object = T(JSON: JSON)
			{
				success(object)
			}
			else
			{
				failure?(UberError(JSON: JSON, response: response))
			}
		}, failure: failure)
	}
}

