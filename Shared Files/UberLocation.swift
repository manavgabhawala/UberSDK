//
//  UberLocation.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation
import CoreLocation
/**
The UberLocation class is a wrapper around a location object provided by Uber. It is contained in several other UberObjects.
*/
@objc public final class UberLocation : JSONCreateable, CustomStringConvertible
{
	/// The current latitude of the vehicle.
	@objc public let latitude : Double
	/// The current longitude of the vehicle.
	@objc public let longitude : Double
	
	/// The current bearing of the vehicle in degrees (0-359).
	@objc public let bearing : Int
	
	/// The name of the location, if it has one.
	@objc public let displayName : String?
	
	/// A CoreLocation representation of the UberLocation
	@objc public var location : CLLocation
	{
		get
		{
			return CLLocation(latitude: latitude, longitude: longitude)
		}
	}
	@objc public var description : String { get { return displayName ?? "Location \(latitude), \(longitude). Orientation \(bearing)°" } }
	
	internal init(latitude : Double, longitude : Double, bearing : Int, displayName: String? = nil)
	{
		self.latitude = latitude
		self.longitude = longitude
		self.bearing = bearing
		self.displayName = displayName
	}
	convenience required public init?(JSON: [NSObject: AnyObject])
	{
		if let latitude = JSON["latitude"] as? Double, let longitude = JSON["longitude"] as? Double
		{
			self.init(latitude : latitude, longitude : longitude, bearing : JSON["bearing"] as? Int ?? 0, displayName: JSON["display_name"] as? String)
			return
		}
		return nil
	}
	/*
	@objc(initWithNullableJSON:)
	convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			self.init(JSON: JSON)
			return
		}
		return nil
	}*/
}