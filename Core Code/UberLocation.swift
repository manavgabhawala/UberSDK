//
//  UberLocation.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/12/15.
//
//

import Foundation
import CoreLocation

@objc public class UberLocation : Printable, DebugPrintable
{
	/// The current latitude of the vehicle.
	@objc public let latitude : Double
	/// The current longitude of the vehicle.
	@objc public let longitude : Double
	/// The current bearing of the vehicle in degrees (0-359).
	@objc public let bearing : Int
	
	/// A CoreLocation representation of the UberLocation
	@objc public var location : CLLocation
		{
		get
		{
			let location = CLLocation(latitude: latitude, longitude: longitude)
			return location
		}
	}
	@objc public var description : String { get { return "Location: \(latitude) \(longitude). Orientation: \(bearing)" } }
	@objc public var debugDescription : String { get { return description } }
	
	private init(latitude : Double, longitude : Double, bearing : Int)
	{
		self.latitude = latitude
		self.longitude = longitude
		self.bearing = bearing
	}
	
	convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			if let latitude = JSON["latitude"] as? Double, let longitude = JSON["longitude"] as? Double, let bearing = JSON["bearing"] as? Int
			{
				self.init(latitude : latitude, longitude : longitude, bearing : bearing)
				return
			}
		}
		self.init(latitude : 0, longitude : 0, bearing : 0)
		return nil
	}
}