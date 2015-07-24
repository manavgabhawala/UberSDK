//
//  UberManager.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 24/07/15.
//
//

import Foundation
import CoreLocation

///  You must implement this protocol to communicate with the UberManager and return information as and when requested. This information can all be found in the Uber app dashboard at `https://developer.uber.com/apps/`.
@objc public protocol UberManagerDelegate : NSObjectProtocol
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
	/// The redirect URI/URL where surge confirmation should be returned to. In swift if not specified, this defaults to the `redirectURI`
	@objc var surgeConfirmationRedirectURI : String { get }
}
extension UberManagerDelegate
{
	var surgeConfirmationRedirectURI : String { return redirectURI }
}

/// This is the main class to which you make calls to access the UberAPI. In general it is best practice to only make one instance of this class and share it across all threads and classes using weak referencing.
@objc public class UberManager : NSObject
{
	//MARK: - General Initializers and Properties
	internal let delegate : UberManagerDelegate
	internal let userAuthenticator : UberUserAuthenticator
	
	internal var surgeCode : String?
	internal let surgeLock = NSLock()
	
	/// Set this property to define the language that the Uber SDK should respond in. The default value of this property is English.
	public var language : Language = .English
	
	///  Dedicated default constructor for an UberManager.
	///
	///  - parameter delegate: The delegate which implements the UberManagerDelegate protocol and returns all the important details required for the Manager to perform API operations on your application's behalf.
	///
	///  - returns: An initialized `UberManager`.
	@objc public init(delegate: UberManagerDelegate)
	{
		self.delegate = delegate
		self.userAuthenticator = UberUserAuthenticator(clientID: delegate.clientID, clientSecret: delegate.clientSecret, redirectURI: delegate.redirectURI, scopes: delegate.scopes.map { UberScopes(rawValue: $0)! } )
		super.init()
	}
	
	///  Use this constructor if you do not wish to create a delegate around one of your classes and just wish to pass in the data once.
	///
	///  - parameter applicationName:              The application name with which you setup the Uber app.
	///  - parameter clientID:                     The client ID for the application setup in Uber
	///  - parameter clientSecret:                 The client secret for the application setup in Uber
	///  - parameter serverToken:                  The server token for the application setup in Uber
	///  - parameter redirectURI:                  The redirect URI/URL for the application setup in Uber
	///  - parameter surgeConfirmationRedirectURI: The redirect URI/URL where surge confirmation should be returned to.
	///  - parameter baseURL:                      This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	///  - parameter scopes:                       An array of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, pass an empty array. This must be an array of `UberScopes`. See the enum type.
	///
	///  - returns: An initialized `UberManager`.
	public convenience init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, surgeConfirmationRedirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes])
	{
		self.init(delegate: PrivateUberDelegate(applicationName: applicationName, clientID: clientID, clientSecret: clientSecret, serverToken: serverToken, redirectURI: redirectURI, baseURL: baseURL, scopes: scopes,surgeConfirmationRedirectURI: surgeConfirmationRedirectURI))
	}
	
	///  Use this constructor if you do not wish to create a delegate around one of your classes and just wish to pass in the data once. Only use this method if you are using Objective C. Otherwise use the other initializer to ensure for type safety.
	///
	///  - parameter applicationName:              The application name with which you setup the Uber app.
	///  - parameter clientID:                     The client ID for the application setup in Uber
	///  - parameter clientSecret:                 The client secret for the application setup in Uber
	///  - parameter serverToken:                  The server token for the application setup in Uber
	///  - parameter redirectURI:                  The redirect URI/URL for the application setup in Uber
	///  - parameter surgeConfirmationRedirectURI: The redirect URI/URL where surge confirmation should be returned to.
	///  - parameter baseURL:                      This is an enumeration that allows you to choose between using the SandboxAPI or the ProductionAPI. You should use the Sandbox while testing and change this to Production before releasing the app. See `UberBaseURL` enumeration.
	///  - parameter scopes:                       An array of raw values of scopes that you would like to request from the user if you are using OAuth2.0. If you don't require user authentication, pass an empty array. This must be an array of Int's formed using the raw values of the enum `UberScopes`
	///
	///  - returns: An initialized `UberManager`.
	@objc public convenience init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, surgeConfirmationRedirectURI: String, baseURL: UberBaseURL, scopes: [Int])
	{
		self.init(delegate: PrivateUberDelegate(applicationName: applicationName, clientID: clientID, clientSecret: clientSecret, serverToken: serverToken, redirectURI: redirectURI, baseURL: baseURL, scopes: scopes.map { UberScopes(rawValue: $0)!}, surgeConfirmationRedirectURI: surgeConfirmationRedirectURI))
	}
	
	
	///  Use this function to log an Uber user out of the system and remove all associated cached files about the user.
	///
	///  - parameter success: The block of code to execute once we have successfully logged a user out.
	///  - parameter failure: An error occurred while logging the user out. Handle the error in this block.
	@objc public func logUberUserOut(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		userAuthenticator.logout(completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Product Fetching
extension UberManager
{
	///  Use this function to fetch uber products for a particular latitude and longitude `asynchronously`.
	///
	///  - parameter latitude:  The latitude for which you want to find Uber products.
	///  - parameter longitude: The longitude for which you want to find Uber products.
	///  - parameter success:   The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchProductsForLocation(latitude latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/products", withPathParameters: ["latitude": latitude, "longitude": longitude], arrayKey: "products", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	///  Use this function to fetch uber products for a particular location `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	///
	///  - parameter location: The location for which you want to find Uber products.
	///  - parameter success:  The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of `UberProducts`. See the `UberProduct` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchProductsForLocation(location: CLLocation, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchProductsForLocation(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
	
	///  Use this function to communicate with the Uber Product Endpoint. You can create an `UberProduct` wrapper using just the productID.
	///
	///  - parameter productID: The productID with which to create a new `UberProduct`
	///  - parameter success:   The block of code to execute if we successfully create the `UberProduct`
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	///  - Warning: Product IDs are different for different regions. Fetch all products for a location using the `UberManager` instance.
	@objc public func createProduct(productID: String, completionBlock success: UberSingleProductSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObject("/v1/products/\(productID)", completionHandler: success, errorHandler: failure)
	}
}

//MARK: - Price Estimates
extension UberManager
{
	///  Use this function to fetch price estimates for a particular trip between two points as defined by you `asynchronously`.
	///
	///  - parameter startLatitude:  The starting latitude for the trip.
	///  - parameter startLongitude: The starting longitude for the trip.
	///  - parameter endLatitude:    The ending latitude for the trip.
	///  - parameter endLongitude:   The ending longitude for the trip.
	///  - parameter success:        The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of `UberPriceEstimates`. See the `UberPriceEstimate` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	@objc public func fetchPriceEstimateForTrip(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObjects("/v1/estimates/price", withPathParameters: ["start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude], arrayKey: "prices", completionHandler: { success($0.0) }, errorHandler: failure)
	}
	
	///  Use this function to fetch price estimates for a particular trip between two points `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.
	///
	///  - parameter startLocation: The starting location for the trip
	///  - parameter endLocation:   The ending location for the trip
	///  - parameter success:       The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	///  - Warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	@objc public func fetchPriceEstimateForTrip(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchPriceEstimateForTrip(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}
//MARK: - Time Estimates
extension UberManager
{
	///  Use this function to fetch time estimates for a particular latitude and longitude `asynchronously`. Optionally, add a productID and/or a userID to narrow down the search results.
	///
	///  - parameter startLatitude:  The starting latitude of the user.
	///  - parameter startLongitude: The starting longitude of the user.
	///  - parameter userID:         An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	///  - parameter productID:      An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	///  - parameter success:        The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of `UberTimeEstimate`s. See the `UberTimeEstimate` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchTimeEstimateForLocation(startLatitude startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
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
	
	///  Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	///
	///  - parameter location:  The location of the user.
	///  - parameter userID:         An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	///  - parameter productID:      An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	///  - parameter success:        The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of `UberTimeEstimate`s. See the `UberTimeEstimate` class for more details on how this is returned.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchTimeEstimateForLocation(location: CLLocation, userID : String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchTimeEstimateForLocation(startLatitude: location.coordinate.latitude, startLongitude: location.coordinate.longitude, userID: userID, productID: productID, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Promotions
extension UberManager
{
	///  Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`.
	///
	///  - parameter startLatitude:  The starting latitude of the user.
	///  - parameter startLongitude: The starting longitude of the user.
	///  - parameter endLatitude:    The ending latitude for the travel.
	///  - parameter endLongitude:   The ending longitude for the travel.
	///  - parameter success:        The block of code to execute if an `UberPromotion` was successfully created. This block takes one parameter the `UberPromotion` object.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchPromotionsForLocations(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObject("/v1/promotions", withPathParameters: ["start_latitude": startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude], completionHandler: success, errorHandler: failure)
	}
	
	/// Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	///
	///  - parameter startLocation: The starting location of the user.
	///  - parameter endLocation:   The ending location for the travel.
	///  - parameter success:        The block of code to execute if an `UberPromotion` was successfully created. This block takes one parameter the `UberPromotion` object.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	@objc public func fetchPromotionsForLocations(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchPromotionsForLocations(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Profile
extension UberManager
{
	///  Use this function to `asynchronously` create an `UberUser`. The uber user gives you access to the logged in user's profile.
	///
	///  - parameter success: The block of code to execute if the user has successfully been created. This block takes one parameter an `UberUser` object.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func createUserProfile(completionBlock success: UberUserSuccess, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before calling this end point")
		fetchObject("/v1/me", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
}

//MARK: - Activity
extension UberManager
{
	///  Use this function to fetch a user's activity data `asynchronously`. This interacts with the v1.1 of the History endpoint and requires the HistoryLite scope.
	///
	///  - parameter offset:  Offset the list of returned results by this amount. Default is zero.
	///  - parameter limit:   Number of items to retrieve. Default is 5, maximum is 50.
	///  - parameter success: The block of code to execute on success. The parameters to this block is an array of `UberActivity`, the offset that is passed in, the limit passed in, the count which is the total number of items available.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@available(*, deprecated=1.1, message="Use instead `fetchUserActivity offset:limit:completionBlock:errorHandler` to use the v1.2 endpoint.")
	@objc public func fetchActivityForUser(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)
	{
		assert(limit <= UberActivity.maximumActivitiesRetrievable, "The maximum limit size supported by this endpoint is \(UberActivity.maximumActivitiesRetrievable). Please pass in a value smaller than this.")
		assert(delegate.scopes.contains(UberScopes.HistoryLite.rawValue), "The HistoryLite scope is required for access to the v1.1 History endpoint. Please make sure you pass this in through the delegate.")
		assert(userAuthenticator.authenticated(), "You must authenticate the user before calling this end point")
		fetchObjects("/v1.1/history", withPathParameters: ["offset" : offset, "limit" : limit], requireUserAccessToken: true, arrayKey: "history", completionHandler: {(activities: [UberActivity], JSON) in
			if let count = JSON["count"] as? Int, let offset = JSON["offset"] as? Int, let limit = JSON["limit"] as? Int
			{
				success(activities, offset: offset, limit: limit, count: count)
				return
			}
			failure?(UberError(JSON: JSON) ?? unknownError)
			}, errorHandler: failure)
	}
	
	///  Use this function to fetch a user's activity data `asynchronously` for v 1.2. It requires the History scope.
	///  - Note: See the `fetchAllUserActivity` function for retrieving all the user's activity at one go.
	///
	///  - parameter offset:  Offset the list of returned results by this amount. Default is zero.
	///  - parameter limit:   Number of items to retrieve. Default is 5, maximum is 50.
	///  - parameter success: The block of code to execute on success. The parameters to this block is an array of `UberActivity`, the offset that is passed in, the limit passed in, the count which is the total number of items available.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func fetchUserActivity(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)
	{
		assert(limit <= UberActivity.maximumActivitiesRetrievable, "The maximum limit size supported by this endpoint is \(UberActivity.maximumActivitiesRetrievable). Please pass in a value smaller than this.")
		assert(delegate.scopes.contains(UberScopes.History.rawValue), "The History scope is required for access to the v1.2 History endpoint. Please make sure you pass this in through the delegate.")
		assert(userAuthenticator.authenticated(), "You must authenticate the user before calling this end point")
		fetchObjects("/v1.2/history", withPathParameters: ["offset" : offset, "limit" : limit], requireUserAccessToken: true, arrayKey: "history", completionHandler: {(activities: [UberActivity], JSON) in
			if let count = JSON["count"] as? Int, let offset = JSON["offset"] as? Int, let limit = JSON["limit"] as? Int
			{
				success(activities, offset: offset, limit: limit, count: count)
				return
			}
			failure?(UberError(JSON: JSON) ?? unknownError)
			}, errorHandler: failure)
	}
	

	///  Use this function to fetch a user's activity data `asynchronously` for v 1.2. It requires the History scope. This function will return all the user's activity after retrieving all of it without any limits however may take longer to run. If you want tor retrieve a smaller number of results and limit and offset the results use the `fetchUserActivity:offset:limit:` function.
	///
	///  - parameter success: The block of code to execute on success. The parameters to this block is an array of `UberActivity`
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func fetchAllUserActivity(completionBlock success: UberAllActivitySuccessCallback, errorHandler failure: UberErrorHandler?)
	{
		assert(delegate.scopes.contains(UberScopes.History.rawValue), "The History scope is required for access to the v1.2 History endpoint. Please make sure you pass this in through the delegate.")
		assert(userAuthenticator.authenticated(), "You must authenticate the user before calling this end point")
		var userActivity = [UberActivity]()
		var count = -1
		let lock = NSLock()
		while count < userActivity.count
		{
			lock.lock()
			fetchUserActivity(offset: userActivity.count, limit: UberActivity.maximumActivitiesRetrievable, completionBlock: { (activities, offset, limit, theCount) -> Void in
				count = theCount
				activities.map { userActivity.append($0) }
				lock.unlock()
				}, errorHandler: failure)
			lock.lock()
		}
		success(userActivity)
	}
}

// MARK: - Request
extension UberManager
{
	
	func createRequest(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, productID: String, surgeConfirmation: String?, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before attempting to use this endpoint.")
		assert(delegate.scopes.contains(UberScopes.Request.rawValue), "You must use the Request scope on your delegate or during initialization to access this endpoint.")
		var queryParameters : [NSObject: AnyObject] = ["start_latitude": startLatitude, "start_longitude": startLongitude, "end_latitude": endLatitude, "end_longitude": endLongitude, "product_id": productID]
		if let surge = surgeConfirmation
		{
			queryParameters["surge_confirmation_id"] = surge
		}
		surgeCode = nil
		fetchObject("/v1/requests", withQueryParameters: queryParameters, requireUserAccessToken: true, usingHTTPMethod: HTTPMethod.Post, completionHandler: success, errorHandler: failure)
	}
	
	///  Use this function to communicate with the Uber Request Endpoint. You can create an `UberRequest` wrapper using just the requestID. You must have authenticated the user with the Request scope before you can use this endpoint.
	///
	///  - parameter requestID: The requestID with which to create a new `UberRequest`
	///  - parameter success:   The block of code to execute if we successfully create the `UberRequest`
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func createRequest(requestID: String, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before attempting to use this endpoint.")
		assert(delegate.scopes.contains(UberScopes.Request.rawValue), "You must use the Request scope on your delegate or during initialization to access this endpoint.")
		fetchObject("/v1/products/\(requestID)", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
	
	/// Use this function to cancel an Uber Request whose request ID you have but do not have the wrapper `UberRequest` object. If you have an `UberRequest` which you want to cancel call the function `cancelRequest:` by passing its id.
	///
	///  - parameter requestID: The request ID for the request you want to cancel.
	///  - parameter success:   The block of code to execute on a successful cancellation.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func cancelRequest(requestID: String, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before using this endpoint.")
		assert(delegate.scopes.contains(UberScopes.Request.rawValue), "You must use the Request scope on your delegate or during initialization to access this endpoint.")
		let request = createRequestForURL("/v1/requests/\(requestID)", requireUserAccessToken: true, usingHTTPMethod: .Delete)
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			guard error != nil && (response as! NSHTTPURLResponse).statusCode == 204
				else
			{
				failure?((error == nil ? UberError(JSONData: data, response: response) : UberError(error: error, response: response)) ?? unknownError)
				return
			}
			success?()
		})
		task.resume()
	}
	
	
	///  Use this function to get the map for an Uber Request whose request ID you have.
	///
	///  - parameter requestID: The request ID for the request whose map you want.
	///  - parameter success:   The block of code to execute on a successful fetching of the map.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func mapForRequest(requestID: String, completionBlock success: UberMapSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before using this endpoint.")
		assert(delegate.scopes.contains(UberScopes.Request.rawValue), "You must use the Request scope on your delegate or during initialization to access this endpoint.")
		fetchObject("/v1/requests/\(requestID)/map", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
	
	///  Use this function to get a receipt for an Uber Request whose request ID you have.
	///
	///  - parameter requestID: The request ID for the request whose receipt you want.
	///  - parameter success:   The block of code to execute on a successful fetching of the receipt.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func receiptForRequest(requestID: String, completionBlock success: UberRequestReceiptSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		assert(userAuthenticator.authenticated(), "You must authenticate the user before using this endpoint.")
		assert(delegate.scopes.contains(UberScopes.RequestReceipt.rawValue), "You must use the Request Receipt scope on your delegate or during initialization to access this endpoint.")
		fetchObject("/v1/requests/\(requestID)/receipt", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
}

// MARK: - Private Helpers
extension UberManager
{
	@objc private class PrivateUberDelegate : NSObject, UberManagerDelegate
	{
		@objc let applicationName : String
		@objc let clientID : String
		@objc let clientSecret: String
		@objc let serverToken : String
		@objc let redirectURI : String
		@objc let baseURL : UberBaseURL
		@objc let scopes : [Int]
		@objc let surgeConfirmationRedirectURI : String
		init(applicationName: String, clientID: String, clientSecret: String, serverToken: String, redirectURI: String, baseURL: UberBaseURL, scopes: [UberScopes], surgeConfirmationRedirectURI: String)
		{
			self.applicationName = applicationName
			self.clientID = clientID
			self.clientSecret = clientSecret
			self.serverToken = serverToken
			self.redirectURI = redirectURI
			self.baseURL = baseURL
			self.scopes = scopes.map { $0.rawValue }
			self.surgeConfirmationRedirectURI = surgeConfirmationRedirectURI
		}
	}
	
	///  Creates a NSURLRequest using the parameters to set it up.
	///
	///  - parameter URL:                 The URL that the request should point to.
	///  - parameter queries:             These are query parameters that are encoded into the HTTP body.
	///  - parameter paths:               These are path parameters that get encoded into the URL.
	///  - parameter accessTokenRequired: This is a boolean that indicates whether the caller requires user authentication or not. If the caller requires user authentication and it hasn't been finished this method fails.
	///  - parameter method:              The HTTP method to use, by default this is a GET request.
	///
	///  - returns: The initialized and fully setup NSURLRequest.
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
	
	///  Performs a network call to the request and calls the success block or failure block depending on what happens on the network call. It parses the JSON and returns it to the success block as a `Dictionary`.
	///
	///  - parameter request: The request on which to perform the network call.
	///  - parameter success: The block of code to exeucte on an error.
	///  - parameter failure: The block of code to execute on an error.
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
				failure?(UberError(JSONData: data, response: response) ?? unknownError)
			}
		})
		task.resume()
	}
	
	///  When multiple objects exist, at the JSON request use this generic function to parse the objects created. The success block must be of the form `([T], [NSObject: AnyObject]) -> Void` where T conforms to JSON createable. See `fetchObject` for only fetching a single object.
	///
	///  - parameter URL:                 The URL on which to perform the request.
	///  - parameter queries:             The queries to use on the request.
	///  - parameter paths:               The path parameters to pass to the request.
	///  - parameter accessTokenRequired: Whether the user access token is required or not.
	///  - parameter method:              The HTTP method to use to perform the request.
	///  - parameter key:                 The key that has the array object.
	///  - parameter success:             The code to exeucte on success.
	///  - parameter failure:             The code to execute on an error.
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
				failure?(UberError(JSON: JSON, response: response) ?? unknownError)
			}
			}, failure: failure)
	}
	
	///  When only one object exists in the JSON use this generic function instead of the `fetchObjects` function.
	///
	///  - parameter URL:                 The URL on which to perform the request.
	///  - parameter queries:             The queries to use on the request.
	///  - parameter paths:               The path parameters to pass to the request.
	///  - parameter accessTokenRequired: Whether the user access token is required or not.
	///  - parameter method:              The HTTP method to use to perform the request.
	///  - parameter success:             The code to exeucte on success.
	///  - parameter failure:             The code to execute on an error.
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
				if let error = UberError(JSON: JSON, response: response)
				{
					failure?(error)
					return
				}
				let errors = UberError.createErrorsWithJSON(JSON, response: response)
				for error in errors
				{
					failure?(error)
				}
				if errors.count == 0
				{
					failure?(unknownError)
				}
			}
			}, failure: failure)
	}
}
