//
//  UberDriver.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/12/15.
//
//

import Foundation

@objc public class UberDriver : Printable, DebugPrintable, UberObjectHasImage
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
	@objc public var debugDescription : String { get { return description } }
	
	private init(name: String, phoneNumber: String, rating: Float, pictureURL: String?)
	{
		self.name = name
		self.phoneNumber = phoneNumber
		self.rating = rating
		if let URL = pictureURL
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
			if let name = JSON["name"] as? String, let phoneNumber = JSON["phone_number"] as? String, let rating = JSON["rating"] as? Float
			{
				self.init(name: name, phoneNumber: phoneNumber, rating: rating, pictureURL: JSON["picture_url"] as? String)
				return
			}
		}
		self.init(name: "", phoneNumber: "", rating: 0, pictureURL: "")
		return nil
	}
}