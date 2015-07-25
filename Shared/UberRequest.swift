//
//  UberRequest.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

/// The Request endpoint allows a ride to be requested on behalf of an Uber user given their desired product, start, and end locations.
@objc public final class UberRequest : NSObject, JSONCreateable
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
	
	@objc public override var description : String { get { return "\(driver) will arrive in a \(vehicle) in about \(eta) minutes." } }
	
	private init(ID: String, status: String, eta: Int, surgeMultiplier: Float, vehicle: [NSObject: AnyObject]?, driver: [NSObject : AnyObject]?, location: [NSObject: AnyObject]?)
	{
		requestID = ID
		self.status = UberRequestStatus(rawValue: status) ?? UberRequestStatus(rawValue: "")!
		self.surgeMultiplier = surgeMultiplier
		self.eta = eta
		self.vehicle = UberVehicle(JSON: vehicle)
		self.driver = UberDriver(JSON: driver)
		self.location = UberLocation(JSON: location)
		super.init()
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		if let ID = JSON["request_id"] as? String, status = JSON["status"] as? String, let eta = JSON["eta"] as? Int
		{
			self.init(ID: ID, status: status, eta: eta, surgeMultiplier: JSON["surge_multiplier"] as? Float ?? 1.0, vehicle: JSON["vehicle"] as? [NSObject: AnyObject], driver: JSON["driver"] as? [NSObject: AnyObject], location: JSON["location"] as? [NSObject: AnyObject])
			return
		}
		return nil
	}
	
	/// This class is a wrapper around a request map.
	@objc public class Map : NSObject, JSONCreateable
	{
		/// Unique identifier representing a Request.
		@objc public let requestID: String
		/// A link to the map of the request.
		@objc public let mapLink : NSURL
		
		public required init?(JSON: [NSObject : AnyObject])
		{
			guard let ID = JSON["request_id"] as? String, let href = JSON["href"] as? String, let URL = NSURL(string: href)
			else
			{
				requestID = ""; mapLink = NSURL(string: "")!;
				super.init()
				return nil
			}
			requestID = ID
			mapLink = URL
			super.init()
		}
	}
}
