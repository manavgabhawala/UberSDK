//
//  UberVehicle.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

/// The UberVehicle is a class that contains information about the vehicle associated with a request.
@objc public final class UberVehicle : NSObject, JSONCreateable, UberObjectHasImage
{
	/// The vehicle make or brand.
	@objc public let make : String
	/// The vehicle model or type.
	@objc public let model : String
	/// The license plate number of the vehicle.
	@objc public let licensePlate: String
	/// The URL to a stock photo of the vehicle (may be null).
	@objc public let imageURL : NSURL?
	
	
	@objc public override var description : String { get { return "\(make) \(model)" } }
	
	required public init?(JSON: [NSObject : AnyObject])
	{
		guard let make = JSON["make"] as? String, let model = JSON["model"] as? String, let licensePlate = JSON["license_plate"] as? String
		else
		{
			self.make = ""; self.model = ""; self.licensePlate = ""; imageURL = nil
			super.init()
			return nil
		}
		self.make = make
		self.model = model
		self.licensePlate = licensePlate
		if let URL = JSON["picture_url"] as? String
		{
			self.imageURL = NSURL(string: URL)
		}
		else
		{
			self.imageURL = nil
		}
		super.init()
	}
}