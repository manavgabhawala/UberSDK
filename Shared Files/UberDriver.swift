//
//  UberDriver.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation
/**
This class contains the information for a driver associated with a request.
*/
@objc public final class UberDriver : JSONCreateable, CustomStringConvertible, UberObjectHasImage
{
	/// The first name of the driver.
	@objc public let name : String
	/// The formatted phone number for contacting the driver.
	@objc public let phoneNumber : String
	/// The URL to the photo of the driver.
	@objc public let imageURL : NSURL?
	/// The driver's star rating out of 5 stars.
	@objc public let rating : Float
	
	@objc public var description : String { get { return "Uber Driver \(name)" } }
	
	required public init?(JSON: [NSObject : AnyObject])
	{
		guard let name = JSON["name"] as? String, let phoneNumber = JSON["phone_number"] as? String, let rating = JSON["rating"] as? Float
			else
			{
				self.name = ""; self.phoneNumber = ""; self.rating = 0; imageURL = nil;
				return nil
			}
		self.name = name
		self.phoneNumber = phoneNumber
		self.rating = rating
		if let URL = JSON["picture_url"] as? String
		{
			self.imageURL = NSURL(string: URL)
		}
		else
		{
			self.imageURL = nil
		}
	}
	/*
	@objc(initWithNullableJSON:)
	convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			self.init(JSON: JSON)
		}
		return nil
	}
	*/
}