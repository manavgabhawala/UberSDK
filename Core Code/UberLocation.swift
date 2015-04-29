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
	
	/// The name of the location, if it has one.
	@availability(*, introduced=1.1)
	@objc public let displayName : String?
	
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
	
	internal init(latitude : Double, longitude : Double, bearing : Int, displayName: String? = nil)
	{
		self.latitude = latitude
		self.longitude = longitude
		self.bearing = bearing
		self.displayName = displayName
	}
	
	convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			if let latitude = JSON["latitude"] as? Double, let longitude = JSON["longitude"] as? Double
			{
				self.init(latitude : latitude, longitude : longitude, bearing : JSON["bearing"] as? Int ?? 0, displayName: JSON["display_name"] as? String)
				return
			}
		}
		self.init(latitude : 0, longitude : 0, bearing : 0)
		return nil
	}
}