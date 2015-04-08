//
//  UberEstimate.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

public class UberEstimate
{
	/// Unique identifier representing a specific product for a given latitude & longitude. For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
	public let productID: String
	/// Display name of product.
	public let productDisplayName: String
	
	private init(id: String, displayName: String)
	{
		self.productID = id
		self.productDisplayName = displayName
	}
}
public typealias UberPriceEstimateSuccessBlock = ([UberPriceEstimate]) -> Void
public class UberPriceEstimate : UberEstimate, Printable, DebugPrintable
{
	/// Upper bound of the estimated price.
	public let highEstimate: Int
	/// Lower bound of the estimated price.
	public let lowEstimate: Int
	/// Formatted string of estimate in local currency of the start location. Estimate could be a range, a single number (flat rate) or "Metered" for TAXI.
	public let estimate: String
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	public let currency: String
	/// Expected activity duration (in seconds). Always show duration in minutes.
	public let duration: NSTimeInterval
	/// Expected activity distance (in miles).
	public let distance: Float
	/// Expected surge multiplier. Surge is active if surge_multiplier is greater than 1. Price estimate already factors in the surge multiplier.
	public let surgeMultiplier: Float
	
	/// A computed property that gives the estimated time of arrival if one were to take the trip for which the price estimate was requested.
	public var ETA: NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: duration)
		}
	}
	
	public var description : String { get { return "Uber Price Estimate: \(estimate) for \(distance) mile long trip, lasting \(duration * 60) minutes." } }
	public var debugDescription : String { get { return description } }
	
	private init(id: String, displayName: String, lowEstimate: Int, highEstimate: Int, estimate: String, currency: String, surge: Float, duration: Int, distance: Float)
	{
		self.highEstimate = highEstimate
		self.lowEstimate = lowEstimate
		self.estimate = estimate
		self.currency = currency
		self.surgeMultiplier = surge
		self.duration = NSTimeInterval(duration)
		self.distance = distance
		super.init(id: id, displayName: displayName)
	}
	private convenience init?(id: String? = nil, displayName: String? = nil, lowEstimate: Int? = nil, highEstimate: Int? = nil, estimate: String? = nil, currency: String? = nil, surge: Float? = nil, duration: Int? = nil, distance: Float? = nil)
	{
		if let id = id, let displayName = displayName, lowEstimate = lowEstimate, let highEstimate = highEstimate, let estimate = estimate, let currency = currency, let surge = surge, let duration = duration, let distance = distance
		{
			self.init(id: id, displayName: displayName, lowEstimate: lowEstimate, highEstimate: highEstimate, estimate: estimate, currency: currency, surge: surge, duration: duration, distance: distance)
		}
		else
		{
			self.init(id: "", displayName: "", lowEstimate: 0, highEstimate: 0, estimate: "", currency: "", surge: 0, duration: 0, distance: 0)
			return nil
		}
	}
	internal convenience init?(JSON: [NSObject: AnyObject])
	{
		self.init(id: JSON["product_id"] as? String, displayName: JSON["display_name"] as? String, lowEstimate: JSON["low_estimate"] as? Int, highEstimate: JSON["high_estimate"] as? Int, estimate: JSON["estimate"] as? String, currency: JSON["currency_code"] as? String, surge: JSON["surge_multiplier"] as? Float, duration: JSON["duration"] as? Int, distance: JSON["distance"] as? Float)
		if self.productID.isEmpty
		{
			return nil
		}
	}
}
public typealias UberTimeEstimateSuccessBlock = ([UberTimeEstimate]) -> Void
public class UberTimeEstimate : UberEstimate, Printable, DebugPrintable
{
	/// ETA for the product (in seconds). Always show estimate in minutes.
	public let estimate : NSTimeInterval
	
	/// This is a computed property that tells you the estimated time of departure for the Uber user if he selects a certian Product.
	public var ETD: NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: estimate)
		}
	}
	public var description : String { get { return "Uber Time Estimate: Estimated time before \(productDisplayName) arrives is \(estimate * 60) minutes." } }
	public var debugDescription : String { get { return description } }
	
	private init(id: String, displayName: String, estimate: Int)
	{
		self.estimate = NSTimeInterval(estimate)
		super.init(id: id, displayName: displayName)
	}
	private convenience init?(id: String?, displayName: String?, estimate: Int?)
	{
		if let id = id, let displayName = displayName, let estimate = estimate
		{
			self.init(id: id, displayName:  displayName, estimate: estimate)
		}
		else
		{
			self.init(id: "", displayName: "", estimate: 0)
			return nil
		}
	}
	internal convenience init?(JSON: [NSObject: AnyObject])
	{
		self.init(id: JSON["product_id"] as? String, displayName: JSON["display_name"] as? String, estimate: JSON["estimate"] as? Int)
		if self.productID.isEmpty
		{
			return nil
		}
	}
}