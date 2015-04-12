//
//  UberManager.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import CoreLocation


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
	/// Return an array of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, return an empty array. This must be an array of UberScopes. See the enum type.
	var scopes : [UberScopes] { get }
}


public typealias UberSuccessBlock = () -> Void

/**
This class is the main wrapper around the über API. Create a instance of this class to communicate with this SDK and make all your main requests using this wrapper.
*/
public class UberManager : NSObject
{
	//MARK: - General Initializers and Properties
	/**
	Dedicated default constructor for an UberManager.
	
	:param: delegate The delegate which implements the UberManagerDelegate protocol and returns all the important details required for the Manager to perform API operations on your application's behalf.
	
	:returns: An initialized UberManager wrapper.
	*/
	public init(delegate: UberManagerDelegate)
	{
		sharedDelegate = delegate
		sharedUserManager = UberUserOAuth()
	}
	
	/**
	Use this constructor if you do not wish to create a delegate around one of your classes and just wish to pass in the data once.
	
	:param: applicationName The application name with which you setup the Uber app.
	:param: clientID        The client ID for the application setup in Uber
	:param: clientSecret    The client secret for the application setup in Uber
	:param: serverToken     The server token for the application setup in Uber
	:param: redirectURI     The redirect URI/URL for the application setup in Uber
	:param: baseURL         This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	:param: scopes          Return an array of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, return an empty array. This must be an array of UberScopes. See the enum type.
	
	:returns: An initialized UberManager wrapper.
	*/
	public convenience init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes])
	{
		self.init(delegate: PrivateUberDelegate(applicationName: applicationName, clientID: clientID, clientSecret: clientSecret, serverToken: serverToken, redirectURI: redirectURI, baseURL: baseURL, scopes: scopes))
	}
	
	/**
	Call this function before using any end points that require user OAuth 2.0. This function will handle displaying the webview and saving and caching the access and refresh tokens to the disk in an encrypted format.
	
	:param: completionBlock The block of code to execute once we have successfully recieved the user's access token.
	:param: errorHandler    An error occurred while getting the user's login. Somehow handle the error in this block.
	*/
	public func performUserAuthorization(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		sharedUserManager.setCallbackBlocks(successBlock: success, errorBlock: failure)
		sharedUserManager.setupOAuth2AccountStore()
	}
	
}

//MARK: - Product Fetching
extension UberManager
{
	/**
	Use this function to fetch uber products for a particular latitude and longitude `asynchronously`.
	
	:param: latitude  		The latitude for which you want to find Uber products.
	:param: longitude 		The longitude for which you want to find Uber products.
	
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	
	:param: errorHandler   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func fetchProductsForLocation(#latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/products", withPathParameters: ["latitude": latitude, "longitude": longitude], arrayKey: "products", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	/**
	Use this function to fetch uber products for a particular location `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location 		The location for which you want to find Uber products.
	
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	
	:param: errorHandler  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func fetchProductsForLocation(location: CLLocation, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchProductsForLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Price Estimates
extension UberManager
{
	/**
	Use this function to fetch price estimates for a particular trip between two points as defined by you `asynchronously`.
	
	:param: startLatitude  	The starting latitude for the trip.
	:param: startLongitude 	The starting longitude for the trip.
	:param: endLatitude    	The ending latitude for the trip.
	:param: endLongitude   	The ending longitude for the trip.
	
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	
	:param: errorHandler   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func fetchPriceEstimateForTrip(#startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/estimates/price", withPathParameters: ["start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude], arrayKey: "prices", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	/**
	Use this function to fetch price estimates for a particular trip between two points `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.
	
	:param: startLocation 	The starting location for the trip
	:param: endLocation   	The ending location for the trip
	
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	
	:param: errorHandler  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func fetchPriceEstimateForTrip(#startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchPriceEstimateForTrip(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Time Estimates
extension UberManager
{
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `asynchronously`. Optionally, add a productID and/or a userID to narrow down the search results.
	
	:param: startLatitude   The starting latitude of the user.
	:param: startLongitude  The starting longitude of the user.
	:param: userID         	An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	:param: productID       An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.
	:param: errorHandler   This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func fetchTimeEstimateForLocation(#startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		var pathParameters : [NSObject: AnyObject] = ["start_latitude": startLatitude, "start_longitude" : startLongitude]
		if let user = userID
		{
			pathParameters["customer_uuid"] = user
		}
		if let product = productID
		{
			pathParameters["product_id"] = product
		}
		fetchObjects("/v1/estimates/time", withPathParameters: pathParameters, arrayKey: "times", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location  		The location of the user.
	:param: productID 		An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: userID    		An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	
	:param: completionBlock The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.
	
	:param: errorHandler 	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func fetchTimeEstimateForLocation(location: CLLocation, productID: String? = nil, userID : String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchTimeEstimateForLocation(startLatitude: location.coordinate.latitude, startLongitude: location.coordinate.longitude, userID: userID, productID: productID, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Promotions
extension UberManager
{
	/**
	Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`.
	
	:param: startLatitude  	The starting latitude of the user.
	:param: startLongitude 	The starting longitude of the user.
	:param: endLatitude    	The ending latitude for the travel.
	:param: endLongitude   	The ending longitude for the travel.
	:param: completionBlock The block of code to execute if an UberPromotion was successfully created. This block takes one parameter the `UberPromotion` object.
	:param: errorHandler   	The block of code to execute if an error occurs.
	*/
	public func fetchPromotionsForLocations(#startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObject("/v1/promotions", withPathParameters: ["start_latitude": startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude], completionHandler: success, errorHandler: failure)
	}
	
	/**
	Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: startLocation 	The starting location of the user.
	:param: endLocation   	The ending location for the travel.
	:param: completionBlock The block of code to execute if an UberPromotion was successfully created. This block takes one parameter the `UberPromotion` object.
	:param: errorHandler  	The block of code to execute if an error occurs.
	*/
	public func fetchPromotionsForLocations(#startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchPromotionsForLocations(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Profile
extension UberManager
{
	/**
	Use this function to `asynchronously` create an Uber User. The uber user gives you access to the logged in user's profile.
	
	:param: completionBlock The block of code to execute if the user has successfully been created. This block takes one parameter an `UberUser` object.
	:param: errorHandler    The block of code to execute if an error occurs.
	*/
	public func createUserProfile(completionBlock success: UberUserSuccess, errorHandler failure: UberErrorHandler?)
	{
		fetchObject("/v1/me", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
}

//MARK: - Activity
extension UberManager
{
	/**
	Use this function to fetch a user's activity data `asynchronously`.
	
	:param: offset           Offset the list of returned results by this amount. Default is zero.
	:param: limit            Number of items to retrieve. Default is 5, maximum is 50.
	:param: completionBlock  The block of code to execute on success. The parameters to this block is an array of `UberActivity`, the offset that is passed in, the limit passed in, the count which is the total number of items available.
	:param: errorHandler     The block of code to execute on failure.
	*/
	public func fetchActivityForUser(offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)
	{
		assert(limit <= 50, "The maximum limit size supported by this endpoint is 50. Please pass in a value smaller than this.")
		fetchObjects("/v1.1/history", withPathParameters: ["offset" : offset, "limit" : limit], requireUserAccessToken: true, arrayKey: "history", completionHandler: {(activities: [UberActivity], JSON) in
			if let count = JSON["count"] as? Int, let offset = JSON["offset"] as? Int, let limit = JSON["limit"] as? Int
			{
				success(activities, offset: offset, limit: limit, count: count)
			}
			uberLog("Could not parse JSON object. Please look at the console to figure out what went wrong.")
			uberLog(JSON)
			failure?(nil, NSError())
		}, errorHandler: failure)
	}
}

// MARK: - Create a New Request
extension UberManager
{
	/**
	Create a new request for the logged in user.
	
	:param: startLatitude   The beginning or "pickup" latitude.
	:param: startLongitude  The beginning or "pickup" longitude.
	:param: endLatitude     The final or destination latitude.
	:param: endLongitude    The final or destination longitude.
	:param: productID       The unique ID of the product being requested.
	:param: completionBlock The block of code to be executed on a successful creation of the request.
	:param: errorHandler    The block of code to be executed if an error occurs.
	*/
	public func createRequest(#startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, productID: String, completionBlock success: UberRequestSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		var successUnwrapped : UberRequestSuccessBlock = {(request: UberRequest) in }
		fetchObject("/v1/requests", withQueryParameters: ["start_latitude": startLatitude, "start_longitude": startLongitude, "end_latitude": endLatitude, "end_longitude": endLongitude, "product_id": productID], requireUserAccessToken: true, usingHTTPMethod: HTTPMethod.Post, completionHandler: success ?? successUnwrapped, errorHandler: failure)
	}
	
	/**
	Create a new request for the logged in user.
	
	:param: startLocation      The beginning or "pickup" location.
	:param: endLocation        The final or destination location.
	:param: productID          The unique ID of the product being requested.
	:param: completionBlock    The block of code to be executed on a successful creation of the request.
	:param: errorHandler       The block of code to be executed if an error occurs.
	*/
	public func createRequest(startLocation: CLLocation, endLocation: CLLocation, productID: String, completionBlock success: UberRequestSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		createRequest(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, productID: productID, completionBlock: success, errorHandler: failure)
	}
}

// MARK: Helper Delegate
extension UberManager
{
	private class PrivateUberDelegate : UberManagerDelegate
	{
		let applicationName : String
		let clientID : String
		let clientSecret: String
		let serverToken : String
		let redirectURI : String
		let baseURL : UberBaseURL
		let scopes : [UberScopes]
		
		init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes])
		{
			self.applicationName = applicationName
			self.clientID = clientID
			self.clientSecret = clientSecret
			self.serverToken = serverToken
			self.redirectURI = redirectURI
			self.baseURL = baseURL
			self.scopes = scopes
		}
	}
}


