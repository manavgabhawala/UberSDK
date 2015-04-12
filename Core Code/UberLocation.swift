//
//  UberLocation.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/12/15.
//
//

import Foundation
import CoreLocation

public class UberLocation : Printable, DebugPrintable
{
	/// The current latitude of the vehicle.
	public let latitude : Double
	/// The current longitude of the vehicle.
	public let longitude : Double
	/// The current bearing of the vehicle in degrees (0-359).
	public let bearing : Int
	
	/// A CoreLocation representation of the UberLocation
	public var location : CLLocation
		{
		get
		{
			let location = CLLocation(latitude: latitude, longitude: longitude)
			return location
		}
	}
	public var description : String { get { return "Location: \(latitude) \(longitude). Orientation: \(bearing)" } }
	public var debugDescription : String { get { return description } }
	
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