//
//  UberUserActivity.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

/// The User Activity endpoint returns a limited amount of data about a user's lifetime activity with Uber. The response will include pickup and dropoff times, the city the trips took place in, the distance of past requests, and information about which products were requested.
@objc public final class UberActivity : NSObject, JSONCreateable
{
	public static let maximumActivitiesRetrievable = 50
	
	/// Unique activity identifier.
	@objc public let UUID: String
	/// Unique identifier representing a specific product for a given latitude & longitude. For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
	@objc public let productID : String
	/// Activity request time
	@objc public let requestTime : NSDate
	/// Status of the activity. See `UberActivityStatus`
	public let status : UberActivityStatus
	/// Length of activity in miles.
	@objc public let distance : Float
	/// Activity start time
	@objc public let startTime : NSDate
	/// Activity end time.
	@objc public let endTime : NSDate
	
	@objc public override var description : String { get { return "Activity \(UUID) for \(distance) miles" } }
	
	/// Details about the city the activity started in.
	@objc public var startCity : UberLocation
	
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	@objc public var currencyCode : String
	
	
	public required init?(JSON : [NSObject: AnyObject])
	{
		guard let UUID = JSON["uuid"] as? String, let request = JSON["request_time"] as? Double, let start = JSON["start_time"] as? NSTimeInterval, let end = JSON["end_time"] as? NSTimeInterval, let distance = JSON["distance"] as? Float, let status = JSON["status"] as? String, let productID = JSON["product_id"] as? String
		else
		{
			self.UUID = ""
			self.requestTime = NSDate(timeIntervalSince1970: 0)
			self.productID = ""
			self.startTime = NSDate(timeIntervalSince1970: 0)
			self.endTime = NSDate(timeIntervalSince1970: 0)
			self.status = UberActivityStatus(rawValue: "")!
			self.distance = 0
			self.startCity = UberLocation(latitude: 0, longitude: 0, bearing: 0)
			self.currencyCode = ""
			super.init()
			return nil
		}
		let requestTime = NSDate(timeIntervalSince1970: request)
		let startTime = NSDate(timeIntervalSince1970: start)
		let endTime = NSDate(timeIntervalSince1970: end)
		self.UUID = UUID
		self.productID = productID
		self.distance = distance
		self.requestTime = requestTime
		self.startTime = startTime
		self.endTime = endTime
		self.status = UberActivityStatus(rawValue: status) ?? UberActivityStatus(rawValue: "")!
		self.startCity = UberLocation(JSON: JSON["start_city"] as? [NSObject: AnyObject]) ?? UberLocation(latitude: 0, longitude: 0, bearing: 0)
		self.currencyCode = JSON["currency_code"] as? String ?? ""
		super.init()
	}
}