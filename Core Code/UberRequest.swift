//
//  UberRequest.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/9/15.
//
//

import Foundation

public enum UberRequestStatus : String
{
	case Processing = "processing"
	case NoDriversAvailable = "no_drivers_available"
	case Accepted = "accepted"
	case Arriving = "arriving"
	case InProgress = "in_progress"
	case DriverCancelled = "driver_canceled"
	case RiderCancelled = "rider_canceled"
	case Completed = "completed"
	case Unknown = ""
}

public typealias UberRequestSuccessBlock = (UberRequest) -> Void
public typealias UberMapSuccessBlock = (UberRequest.Map) -> Void

@objc public class UberRequest : Printable, DebugPrintable, JSONCreateable
{
	
	/// The unique ID of the Request.
	@objc public let requestID: String
	
	/// The status of the Request indicating state.
	public let status : UberRequestStatus
	
	/// The estimated arrival time of vehicle arrival in minutes.
	@objc public let eta : Int
	/// The estimated arrival time of vehicle arrival as an NSDate
	@objc public var estimatedTimeOfArrival : NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: Double(eta) * 60.0)
		}
	}
	
	/// The surge pricing multiplier used to calculate the increased price of a Request. A multiplier of 1.0 means surge pricing is not in effect.
	@objc public let surgeMultiplier : Float
	
	/// The object that contains the vehicle details.
	@objc public let vehicle : UberVehicle?
	
	/// The object that contains driver details.
	@objc public let driver : UberDriver?
	
	/// The object that contains the location information of the vehicle and driver.
	@objc public let location : UberLocation?

	public var description : String { get { return "\(driver) will arrive in a \(vehicle) in about \(eta) minutes." } }
	public var debugDescription : String { get { return description } }
	
	private init(ID: String, status: String, eta: Int, surgeMultiplier: Float, vehicle: [NSObject: AnyObject]?, driver: [NSObject : AnyObject]?, location: [NSObject: AnyObject]?)
	{
		requestID = ID
		self.status = UberRequestStatus(rawValue: status) ?? UberRequestStatus(rawValue: "")!
		self.surgeMultiplier = surgeMultiplier
		self.eta = eta
		self.vehicle = UberVehicle(JSON: vehicle)
		self.driver = UberDriver(JSON: driver)
		self.location = UberLocation(JSON: location)
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		if let ID = JSON["request_id"] as? String, status = JSON["status"] as? String, let eta = JSON["eta"] as? Int
		{
			self.init(ID: ID, status: status, eta: eta, surgeMultiplier: JSON["surge_multiplier"] as? Float ?? 1.0, vehicle: JSON["vehicle"] as? [NSObject: AnyObject], driver: JSON["driver"] as? [NSObject: AnyObject], location: JSON["location"] as? [NSObject: AnyObject])
			return
		}
		self.init(ID: "", status: "", eta: 0, surgeMultiplier: 0, vehicle: nil, driver: nil, location: nil)
		return nil
	}
	
	/**
	Use this function to cancel the request that `self` points to.
	
	:param: completionBlock The block of code to execute on a successful cancellation.
	:param: errorHandler 	The block of code to execute on a failure to cancel the request.
	*/
	public func cancel(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		UberRequest.cancelRequest(self.requestID, completionBlock: success, errorHandler: failure)
	}
	
	/**
	Use this function to get the map for the request that `self` points to.
	
	:param: completionBlock The block of code to execute on a successful fetching of the map.
	:param: errorHandler 	The block of code to execute if an error occurs.
	*/
	public func getRequestMap(completionBlock success: UberMapSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		UberRequest.mapForRequest(requestID, completionBlock: success, errorHandler: failure)
	}
	
	/**
	Use this function to communicate with the Uber Request Endpoint. You can create an `UberRequest` wrapper using just the requestID.
	
	:param: requestID 		The requestID with which to create a new `UberRequest`
	:param: completionBlock The block of code to execute if we successfully create the `UberRequest`
	:param: errorHandler    The block of code to execute if an error occurs.
	
	*/
	public class func createRequest(requestID: String, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		assert(sharedDelegate != nil, "You must initialize the UberManager before being able to call methods on the Uber SDK.")
		fetchObject("/v1/products/\(requestID)", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
	
	/**
	Use this function to cancel an Uber Request whose request ID you have but do not have the wrapper `UberRequest` object. If you have an `UberRequest` which you want to cancel call the member function `cancel:` on the object.
	
	:param: requestID 		The request ID for the request you want to cancel.
	:param: completionBlock The block of code to execute on a successful cancellation.
	:param: errorHandler    The block of code to execute on a failure to cancel the request.
	*/
	public class func cancelRequest(requestID: String, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		let request = createRequestForURL("/v1/requests/\(requestID)", requireUserAccessToken: true, usingHTTPMethod: .Delete)
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			if (error == nil && (response as! NSHTTPURLResponse).statusCode == 204)
			{
				success?()
			}
			else
			{
				failure?(response, error)
			}
		})
	}
	
	/**
	Use this function to get the map for an Uber Request whose request ID you have but do not have the wrapper `UberRequest` object. If you have an `UberRequest` for which you want to get the map call the member function `getRequestMap:` on the object.
	
	:param: requestID 		 The request ID for the request whose map you want.
	:param: completionBlock  The block of code to execute on a successful fetching of the map.
	:param: errorHandler     The block of code to execute if an error occurs.
	*/
	public class func mapForRequest(requestID: String, completionBlock success: UberMapSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		fetchObject("/v1/requests/\(requestID)/map", requireUserAccessToken: true, completionHandler: success, errorHandler: failure)
	}
	
	/**
	This class is a wrapper around a request map.
	*/
	public class Map : JSONCreateable
	{
		/// Unique identifier representing a Request.
		public let requestID: String
		/// A link to the map of the request.
		public let mapLink : NSURL
		
		private init(requestID: String, href: String)
		{
			self.requestID = requestID
			self.mapLink = NSURL(string: href) ?? NSURL(string: "")!
		}
		
		public convenience required init?(JSON: [NSObject : AnyObject])
		{
			if let ID = JSON[""] as? String, let href = JSON[""] as? String
			{
				self.init(requestID: ID, href: href)
				if self.mapLink.absoluteString == nil || self.mapLink.absoluteString!.isEmpty
				{
					return nil
				}
				return
			}
			self.init(requestID: "", href: "")
			return nil
		}
	}
}


