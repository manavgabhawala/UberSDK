//
//  UberTimeEstimate.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

/// The Time Estimates endpoint returns ETAs for all products offered at a given location, with the responses expressed as integers in seconds. Uber recommends that this endpoint be called every minute to provide the most accurate, up-to-date ETAs.
@objc public final class UberTimeEstimate : UberEstimate, JSONCreateable
{
	/// ETA for the product (in seconds). Always show estimate in minutes.
	@objc public let estimate : NSTimeInterval
	
	/// This is a computed property that tells you the estimated time of departure for the Uber user if he selects a certian Product.
	@objc public var ETD: NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: estimate)
		}
	}
	
	@objc public override var description : String { get { return "Uber Time Estimate: Estimated time before \(productDisplayName) arrives is \(estimate * 60) minutes." } }
	
	required override public init?(JSON: [NSObject: AnyObject])
	{
		guard let estimate = JSON["estimate"] as? Int
			else { self.estimate = 0; super.init(JSON: JSON)
				return nil }
		self.estimate = NSTimeInterval(estimate)
		super.init(JSON: JSON)
	}
}
