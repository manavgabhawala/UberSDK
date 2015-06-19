//
//  UberRequestReceipt.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

@objc public final class UberRequestReceipt : CustomStringConvertible, JSONCreateable
{
	/// Unique identifier representing a Request.
	@objc public let requestID: String
	/// Describes the charges made against the rider.
	@objc public let charges : [UberReceiptDetail]
	/// Describes the surge charge. May be null if surge pricing was not in effect.
	@objc public let surgeCharge : UberReceiptDetail?
	/// Adjustments made to the charges such as promotions, and fees.
	@objc public let chargeAdjustments : [UberReceiptDetail]
	/// The summation of the charges.
	@objc public let normalFare : Double
	/// The summation of the normal_fare and surge_charge.
	@objc public let subtotal : Double
	/// The total amount charged to the users payment method. This is the the subtotal (split if applicable) with taxes included.
	@objc public let totalCharged : Double
	/// The total amount still owed after attempting to charge the user. May be null if amount was paid in full.
	@objc public let totalOwed : Double
	
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	@objc public let currencyCode : String
	/// Time duration of the trip in ISO 8061 HH:MM:SS format.
	@objc public let duration : String
	/// Time duration of the trip as an NSTimeInterval.
	@objc public var timeDuration : NSTimeInterval
	{
		get
		{
			let components = duration.componentsSeparatedByString(":")
			assert(components.count == 3, "There needs to be 3 components in the time. The hours, minutes and seconds. The string provided was \(duration)")
			let hours = Double(components.first!)!
			let minutes = Double(components[1])!
			let seconds = Double(components.last!)!
			return (((hours * 60.0) + minutes) * 60.0) + seconds
		}
	}
	
	/// Distance of the trip charged.
	@objc public let distance : String
	
	/// The localized unit of distance.
	@objc public let distanceUnits : String
	
	@objc public var description : String { return "Receipt for trip \(timeDuration) and \(distance)\(distanceUnits) long. Total Cost: \(totalCharged)\(currencyCode)" }
	
	public required init?(JSON: [NSObject : AnyObject])
	{
		surgeCharge = UberReceiptDetail(JSON: JSON["surge_charge"] as? [NSObject: AnyObject])
		guard let id = JSON["request_id"] as? String, let normal = JSON["normal_fare"] as? Double, let sub = JSON["subtotal"] as? Double, let charged = JSON["total_charged"] as? Double, let owed = JSON["total_owed"] as? Double, let currency = JSON["currency_code"] as? String, let dur = JSON["duration"] as? String, let dist = JSON["distance"] as? String, let distUnits = JSON["distance_label"] as? String
		else {
			requestID = ""; normalFare = 0; subtotal = 0; totalCharged = 0; totalOwed = 0; currencyCode = ""; duration = ""; distance = ""; distanceUnits = ""; charges = []; chargeAdjustments = []
			return nil }
		requestID = id
		normalFare = normal
		subtotal = sub
		totalCharged = charged
		totalOwed = owed
		currencyCode = currency
		duration = dur
		distance = dist
		distanceUnits = distUnits
		charges = UberReceiptDetail.createArray(JSON["charges"] as? [[NSObject: AnyObject]])
		chargeAdjustments = UberReceiptDetail.createArray(JSON["charge_adjustments"] as? [[NSObject: AnyObject]])
	}
}

/**
A generalized class that can be a part of a receipt either as surge charge, a charge adjustment or even the general charges field.
*/
@objc public final class UberReceiptDetail : CustomStringConvertible, JSONCreateable
{
	/// The name of the charge.
	@objc public let name: String
	/// The amount
	@objc public let amount: Double
	
	/// The type of the receipt. Can be used in Swift only. For objective-c see the receiptType property.
	public let type: UberReceiptDetailType
	
	/// The type of the receipt as a string. For Swift type-safety, see the type property and the UberReceiptDetailType enum.
	@objc public var receiptType : String { return type.rawValue }
	
	@objc public var description : String { return "Receipt Detail \(name) amounted to \(amount)" }
	
	public init?(JSON: [NSObject : AnyObject])
	{
		guard let name = JSON["name"] as? String, let amount = JSON["amount"] as? Double, let rawType = JSON["type"] as? String else {
			self.name = ""; self.amount = 0; self.type = .Unknown
			return nil }
		self.name = name
		self.amount = amount
		self.type = UberReceiptDetailType(rawValue: rawType) ?? .Unknown
	}
	class func createArray(JSON: [[NSObject: AnyObject]]?) -> [UberReceiptDetail]
	{
		var array = [UberReceiptDetail]()
		guard let JSON = JSON else { return array }
		for item in JSON
		{
			if let newDetail = UberReceiptDetail(JSON: item)
			{
				array.append(newDetail)
			}
		}
		return array
	}
}
/**
An enumeration that contains the possible types for an uber receipt.
*/
public enum UberReceiptDetailType : String
{
	case BaseFare = "base_fare"
	case Distance = "distance"
	case Time = "time"
	case Surge = "surge"
	case SafeRideFee = "safe_ride_fee"
	case RoundingDown = "rounding_down"
	case Promotion = "promotion"
	case Unknown = "unknown"
}