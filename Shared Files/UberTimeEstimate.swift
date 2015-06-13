//
//  UberTimeEstimate.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

@objc public class UberTimeEstimate : UberEstimate
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
	@objc public override var debugDescription : String { get { return description } }
	
	
	public required init?(JSON: [NSObject: AnyObject])
	{
		guard let estimate = JSON["estimate"] as? Int
			else { self.estimate = 0; super.init(JSON: JSON)
				return nil }
		self.estimate = NSTimeInterval(estimate)
		super.init(JSON: JSON)
	}
}
