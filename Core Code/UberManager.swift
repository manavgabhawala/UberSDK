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
	
}
//MARK: - Product Fetching
extension UberManager
{
	/**
	Use this function to fetch uber products for a particular location `synchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location The location for which you want to find Uber products.
	:param: response The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error    An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberProducts for a location. nil if an error occurs. We will also log the number of products found for your convienence. See the `UberProduct` class for more details on how this is returned.
	*/
	public func synchronouslyFetchProducts(#location: CLLocation, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberProduct]?
	{
		return synchronouslyFetchProducts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, response: response, error: error)
	}
	
	/**
	Use this function to fetch uber products for a particular latitude and longitude `synchronously`.
	
	:param: latitude  The latitude for which you want to find Uber products.
	:param: longitude The longitude for which you want to find Uber products.
	:param: response  The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error     An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberProducts for a location. nil if an error occurs. We will also log the number of products found for your convienence. See the `UberProduct` class for more details on how this is returned.
	*/
	public func synchronouslyFetchProducts(#latitude: Double, longitude: Double, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberProduct]?
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/products", withPathParameters: ["latitude" : latitude, "longitude" : longitude])
		var err : NSError?
		if error != nil
		{
			err = error.memory
		}
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: &err)
		var JSONData: NSDictionary? = nil
		var JSONError : NSError?
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
		}
		if (err == nil)
		{
			if let productsJSON = JSONData?.objectForKey("products") as? [[NSObject : AnyObject]]
			{
				let products = productsJSON.map { UberProduct(JSON: $0) }
				let actualProducts = products.filter { $0 != nil }.map { $0! }
				uberLog("Number of products found: \(actualProducts.count)")
				return actualProducts
			}
			uberLog("Error parsing Product JSON. Please look at the console to see the JSON that got parsed.")
			uberLog(JSONData)
			uberLog(JSONError)
		}
		else
		{
			uberLog(JSONData)
		}
		return nil
	}
	
	/**
	Use this function to fetch uber products for a particular location `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location The location for which you want to find Uber products.
	:param: completionBlock  The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	:param: errorHandler  This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func asynchronouslyFetchProducts(#location: CLLocation, completionBlock success: UberProductSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		asynchronouslyFetchProducts(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
	
	/**
	Use this function to fetch uber products for a particular latitude and longitude `asynchronously`.
	
	:param: latitude  The latitude for which you want to find Uber products.
	:param: longitude The longitude for which you want to find Uber products.
	:param: completionBlock   The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.
	:param: errorHandler   This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func asynchronouslyFetchProducts(#latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/products", withPathParameters: ["latitude": latitude, "longitude": longitude])
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

//MARK: - Price Estimates
extension UberManager
{
	/**
	Use this function to fetch price estimates for a particular trip between two points as defined by you `synchronously`.
	
	:param: startLatitude  The starting latitude for the trip.
	:param: startLongitude The starting longitude for the trip.
	:param: endLatitude    The ending latitude for the trip.
	:param: endLongitude   The ending longitude for the trip.
	:param: response       The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error          An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberPriceEstimatess for the trip with different products. nil if an error occurs. We will also log the number of price estimates found for your convienence. See the `UberPriceEstimate` class for more details on how this is returned.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func synchronouslyFetchPriceEstimateForTrip(#startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberPriceEstimate]?
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/estimates/price", withPathParameters: ["start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude])
		var err : NSError?
		if (error != nil)
		{
			err = error.memory
		}
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: &err)
		var JSONData: NSDictionary? = nil
		var JSONError : NSError?
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
		}
		if (err == nil)
		{
			if let priceEstimateJSON = JSONData?.objectForKey("prices") as? [[NSObject : AnyObject]]
			{
				let priceEstimates = priceEstimateJSON.map { UberPriceEstimate(JSON: $0) }.filter { $0 != nil }.map { $0! }
				uberLog("Number of price estimates found: \(priceEstimates.count)")
				return priceEstimates
			}
			uberLog("Error parsing Product JSON. Please look at the console to see the JSON that got parsed.")
			uberLog(JSONData)
			uberLog(JSONError)
		}
		else
		{
			uberLog(JSONData)
		}
		return nil
	}
	
	/**
	Use this function to fetch price estimates for a particular trip between two points `synchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.
	
	:param: startLocation The starting location for the trip
	:param: endLocation   The ending location for the trip
	:param: response      The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error         An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberPriceEstimatess for the trip with different products. nil if an error occurs. We will also log the number of price estimates found for your convienence. See the `UberPriceEstimate` class for more details on how this is returned.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func synchronouslyFetchPriceEstimateForTrip(#startLocation: CLLocation, endLocation: CLLocation, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberPriceEstimate]?
	{
		return synchronouslyFetchPriceEstimateForTrip(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, response: response, error: error)
	}
	/**
	Use this function to fetch price estimates for a particular trip between two points as defined by you `asynchronously`.
	
	:param: startLatitude  The starting latitude for the trip.
	:param: startLongitude The starting longitude for the trip.
	:param: endLatitude    The ending latitude for the trip.
	:param: endLongitude   The ending longitude for the trip.
	:param: success        The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	:param: failure        This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func asynchronouslyFetchPriceEstimateForTrip(#startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/estimates/price", withPathParameters: ["start_latitude" : startLatitude, "start_longitude" : startLongitude, "end_latitude" : endLatitude, "end_longitude" : endLongitude])
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			if (error == nil)
			{
				var JSONError: NSError?
				if let JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
				{
					if let priceEstimatesJSON = JSONData.objectForKey("prices") as? [[NSObject: AnyObject]]
					{
						let priceEstimates = priceEstimatesJSON.map { UberPriceEstimate(JSON: $0) }.filter { $0 != nil }.map { $0! }
						uberLog("Number of price estimates found: \(priceEstimates.count)")
						success?(priceEstimates)
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
	
	/**
	Use this function to fetch price estimates for a particular trip between two points `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.
	
	:param: startLocation The starting location for the trip
	:param: endLocation   The ending location for the trip
	:param: success       The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.
	:param: failure       This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	
	:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
	*/
	public func asynchronouslyFetchPriceEstimateForTrip(#startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		asynchronouslyFetchPriceEstimateForTrip(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.longitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Time Estimates
extension UberManager
{
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results.
	
	:param: startLatitude  The starting latitude of the user.
	:param: startLongitude The starting longitude of the user.
	:param: userID         An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	:param: productID      An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: response       The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error          An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberTimeEstimates for a location. nil if an error occurs. We will also log the number of time estimates found for your convienence. See the `UberTimeEstimate` class for more details on how this is returned.
	*/
	public func synchronouslyFetchTimeEstaimateForLocation(#startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberTimeEstimate]?
	{
		var pathParatmeters : [NSObject: AnyObject] = ["start_latitude": startLatitude, "start_longitude" : startLongitude]
		if let user = userID
		{
			pathParatmeters["customer_uuid"] = user
		}
		if let product = productID
		{
			pathParatmeters["product_id"] = product
		}
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/estimates/time", withPathParameters: pathParatmeters)
		var err : NSError?
		if (error != nil)
		{
			err = error.memory
		}
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: &err)
		var JSONData: NSDictionary? = nil
		var JSONError : NSError?
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
		}
		if (err == nil)
		{
			if let timeEstimatesJSON = JSONData?.objectForKey("times") as? [[NSObject : AnyObject]]
			{
				let timeEstimates = timeEstimatesJSON.map { UberTimeEstimate(JSON: $0) }.filter { $0 != nil }.map { $0! }
				uberLog("Number of time estimates found: \(timeEstimates.count)")
				return timeEstimates
			}
			uberLog("Error parsing Time Estimate JSON. Please look at the console to see the JSON that got parsed.")
			uberLog(JSONData)
			uberLog(JSONError)
		}
		else
		{
			uberLog(JSONData)
		}
		return nil
	}
	
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location  The location of the user.
	:param: productID An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: userID    An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	:param: response  The NSURLResponse will be stored in the variable passed by reference to this function.
	:param: error     An error pointer, if an error occurs, the error will be stored in this variable.
	
	:returns: An array of UberTimeEstimates for a location. nil if an error occurs. We will also log the number of time estimates found for your convienence. See the `UberTimeEstimate` class for more details on how this is returned.
	*/
	public func synchronouslyFetchTimeEstaimateForLocation(#location: CLLocation, productID: String? = nil, userID : String? = nil, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> [UberTimeEstimate]?
	{
		return synchronouslyFetchTimeEstaimateForLocation(startLatitude: location.coordinate.latitude, startLongitude: location.coordinate.longitude, userID: userID, productID: productID, response: response, error: error)
	}
	
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `asynchronously`. Optionally, add a productID and/or a userID to narrow down the search results.
	
	:param: startLatitude  The starting latitude of the user.
	:param: startLongitude The starting longitude of the user.
	:param: userID         An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	:param: productID      An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: success        The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.
	:param: failure        This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func asynchronouslyFetchTimeEstaimateForLocation(#startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		var pathParatmeters : [NSObject: AnyObject] = ["start_latitude": startLatitude, "start_longitude" : startLongitude]
		if let user = userID
		{
			pathParatmeters["customer_uuid"] = user
		}
		if let product = productID
		{
			pathParatmeters["product_id"] = product
		}
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/estimates/time", withPathParameters: pathParatmeters)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			var JSONError: NSError?
			if (error == nil)
			{
				if let JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
				{
					if let timeEstimatesJSON = JSONData.objectForKey("times") as? [[NSObject: AnyObject]]
					{
						let timeEstimates = timeEstimatesJSON.map { UberTimeEstimate(JSON: $0) }.filter { $0 != nil }.map { $0! }
						uberLog("Number of time estimates found: \(timeEstimates.count)")
						success?(timeEstimates)
						return
					}
					uberLog("No time estimates found inside of JSON object. Please look at the console to figure out what went wrong.")
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
	
	/**
	Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.
	
	:param: location  The location of the user.
	:param: productID An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
	:param: userID    An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
	:param: success   The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.
	:param: failure   This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
	*/
	public func asynchronouslyFetchTimeEstaimateForLocation(#location: CLLocation, productID: String? = nil, userID : String? = nil, completionBlock success: UberTimeEstimateSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		asynchronouslyFetchTimeEstaimateForLocation(startLatitude: location.coordinate.latitude, startLongitude: location.coordinate.longitude, userID: userID, productID: productID, completionBlock: success, errorHandler: failure)
	}
}

//MARK: - Promotions
extension UberManager
{
	public func synchronouslyFetchPromotionsForLocation(startLatitude: Double! = nil, startLongitude: Double! = nil, endLatitude: Double! = nil, endLongitude: Double! = nil, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> UberPromotion?
	{
		assert((startLatitude != nil && startLongitude != nil) || (endLatitude != nil && endLongitude != nil), "At least one location must be specified for the promotions end point.")
		assert((startLatitude != nil) == (startLongitude != nil), "If you specify the start latitude/longitude you must also specify the other end coordinate. Start Latitude: \(startLatitude), Start Longitude: \(startLongitude)")
		assert((endLatitude != nil) == (endLongitude != nil), "If you specify the end latitude/longitude you must also specify the other end coordinate. End Latitude: \(endLatitude), End Longitude: \(endLongitude)")
		var pathParamters = [NSObject: AnyObject]()
		if startLatitude != nil
		{
			pathParamters["start_latitude"] = startLatitude
			pathParamters["start_longitude"] = startLongitude
		}
		if endLatitude != nil
		{
			pathParamters["end_latitude"] = endLatitude
			pathParamters["end_longitude"] = endLongitude
		}
		let request = createRequestForURL("\(sharedDelegate.baseURL.URL)/v1/promotions", withPathParameters: pathParamters)
		var err : NSError?
		if (error != nil)
		{
			err = error.memory
		}
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: response, error: &err)
		var JSONData: NSDictionary? = nil
		var JSONError : NSError?
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? NSDictionary
		}
		if (err == nil)
		{
			if let JSON = JSONData as? [NSObject : AnyObject]
			{
				println(JSON)
				let promotion = UberPromotion(JSON: JSON)
				return promotion
			}
			uberLog("Error parsing Product JSON. Please look at the console to see the JSON that got parsed.")
			uberLog(JSONData)
			uberLog(JSONError)
		}
		else
		{
			uberLog(JSONData)
		}
		return nil
	}
	
	public func synchronouslyFetchPromotionsForLocation(startLocation: CLLocation! = nil, endLocation: CLLocation! = nil, response: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error: NSErrorPointer) -> UberPromotion?
	{
		assert(startLocation != nil || endLocation != nil, "At least one location must be specified for the promotions end point.")
		let startLatitude = startLocation?.coordinate.latitude
		let startLongitude = startLocation?.coordinate.longitude
		let endLatitude = endLocation?.coordinate.latitude
		let endLongitude = endLocation?.coordinate.longitude
		
		return synchronouslyFetchPromotionsForLocation(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, response: response, error: error)
	}
}

//MARK: - Private Helpers
extension UberManager
{
}
