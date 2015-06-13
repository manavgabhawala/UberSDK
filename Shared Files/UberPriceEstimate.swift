//
//  UberPriceEstimate.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

public class UberPriceEstimate : UberEstimate
{
	/// Upper bound of the estimated price.
	@objc public let highEstimate: Int
	/// Lower bound of the estimated price.
	@objc public let lowEstimate: Int
	/// Formatted string of estimate in local currency of the start location. Estimate could be a range, a single number (flat rate) or "Metered" for TAXI.
	@objc public let estimate: String
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	@objc public let currency: String
	/// Expected activity duration (in seconds). Always show duration in minutes.
	@objc public let duration: NSTimeInterval
	/// Expected activity distance (in miles).
	@objc public let distance: Float
	/// Expected surge multiplier. Surge is active if surge_multiplier is greater than 1. Price estimate already factors in the surge multiplier.
	@objc public let surgeMultiplier: Float
	
	/// A computed property that gives the estimated time of arrival if one were to take the trip for which the price estimate was requested.
	@objc public var ETA: NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: duration)
		}
	}
	
	@objc public override var description : String { get { return "Uber Price Estimate: \(estimate) for \(distance) mile long trip, lasting \(duration * 60) minutes." } }
	@objc public override var debugDescription : String { get { return description } }
	
	
	private init?(JSON: [NSObject : AnyObject], lowEstimate: Int? = nil, highEstimate: Int? = nil, estimate: String? = nil, currency: String? = nil, surge: Float? = nil, duration: Int? = nil, distance: Float? = nil)
	{
		guard let lowEstimate = lowEstimate, let highEstimate = highEstimate, let estimate = estimate, let currency = currency, let surge = surge, let duration = duration, let distance = distance
			else
			{
				self.lowEstimate = 0; self.highEstimate = 0; self.estimate = ""; self.currency = ""; self.surgeMultiplier = 0; self.duration = 0; self.distance = 0;
				super.init(JSON: JSON)
				return nil
			}
		
		self.highEstimate = highEstimate
		self.lowEstimate = lowEstimate
		self.estimate = estimate
		self.currency = currency
		self.surgeMultiplier = surge
		self.duration = NSTimeInterval(duration)
		self.distance = distance
		super.init(JSON: JSON)
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		self.init(JSON: JSON, lowEstimate: JSON["low_estimate"] as? Int, highEstimate: JSON["high_estimate"] as? Int, estimate: JSON["estimate"] as? String, currency: JSON["currency_code"] as? String, surge: JSON["surge_multiplier"] as? Float, duration: JSON["duration"] as? Int, distance: JSON["distance"] as? Float)
		if self.productID.isEmpty
		{
			return nil
		}
	}
}