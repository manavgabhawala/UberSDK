//
//  UberActivity.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/9/15.
//
//

import Foundation

public typealias UberActivitySuccessCallback = ([UberActivity], offset: Int, limit: Int, count: Int) -> Void

public enum UberActivityStatus : String
{
	case Completed = "completed"
	case Unknown = "Unknown"
}

@objc public class UberActivity : Printable, DebugPrintable, JSONCreateable
{
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
	
	@objc public var description : String { get { return "Activity \(UUID) for \(distance) miles" } }
	@objc public var debugDescription : String { get { return description } }
	
	/**
	Details about the city the activity started in.
	*/
	@availability(*, introduced=1.1)
	@objc public var startCity : UberLocation
	
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	@availability(*, introduced=1.1)
	@objc public var currencyCode : String
	
	private init?(UUID: String?, productID: String?, requestTime: NSTimeInterval?, startTime : NSTimeInterval?, endTime: NSTimeInterval?, status: String?, distance: Float?, currencyCode: String?, startCity: UberLocation?)
	{
		if let UUID = UUID, let request = requestTime, let start = startTime, let end = endTime, let distance = distance, let status = status, let productID = productID
		{
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
			self.startCity = startCity ?? UberLocation(latitude: 0, longitude: 0, bearing: 0)
			self.currencyCode = currencyCode ?? ""
			return
		}
		self.UUID = ""
		self.requestTime = NSDate(timeIntervalSince1970: 0)
		self.productID = ""
		self.startTime = NSDate(timeIntervalSince1970: 0)
		self.endTime = NSDate(timeIntervalSince1970: 0)
		self.status = UberActivityStatus(rawValue: "")!
		self.distance = 0
		self.startCity = UberLocation(latitude: 0, longitude: 0, bearing: 0)
		self.currencyCode = ""
		return nil
	}
	
	public convenience required init?(JSON : [NSObject: AnyObject])
	{
		self.init(UUID: JSON["uuid"] as? String, productID: JSON["product_id"] as? String, requestTime: JSON["request_time"] as? Double, startTime: JSON["start_time"] as? NSTimeInterval, endTime: JSON["end_time"] as? NSTimeInterval, status: JSON["status"] as? String, distance: JSON["distance"] as? Float, currencyCode: JSON["currency_code"] as? String, startCity: UberLocation(JSON: JSON["start_city"] as? [NSObject: AnyObject]))
		if UUID.isEmpty
		{
			return nil
		}
	}
}