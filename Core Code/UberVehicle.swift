//
//  UberVehicle.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/12/15.
//
//

import Foundation

@objc public class UberVehicle : Printable, DebugPrintable, UberObjectHasImage
{
	/// The vehicle make or brand.
	@objc public let make : String
	/// The vehicle model or type.
	@objc public let model : String
	/// The license plate number of the vehicle.
	@objc public let licensePlate: String
	/// The URL to a stock photo of the vehicle (may be null).
	@objc public let imageURL : NSURL?
	
	
	@objc public var description : String { get { return "\(make) \(model)" } }
	@objc public var debugDescription : String { get { return description } }
	
	private init(make : String, model : String, licensePlate : String, imageURL : String?)
	{
		self.make = make
		self.model = model
		self.licensePlate = licensePlate
		if let URL = imageURL
		{
			self.imageURL = NSURL(string: URL)
		}
		else
		{
			self.imageURL = nil
		}
		
	}
	
	convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			if let make = JSON["make"] as? String, let model = JSON["model"] as? String, let licensePlate = JSON["license_plate"] as? String
			{
				self.init(make : make, model : model, licensePlate : licensePlate, imageURL : JSON["picture_url"] as? String)
				return
			}
		}
		self.init(make : "", model : "", licensePlate : "", imageURL : "")
		return nil
	}
}