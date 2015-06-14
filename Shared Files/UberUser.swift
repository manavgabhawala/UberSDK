//
//  UberUser.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

/**
The User Profile endpoint returns information about the Uber user that has authorized with the application.
*/
@objc public final class UberUser : CustomStringConvertible, JSONCreateable, UberObjectHasImage
{
	/// First name of the Uber user.
	@objc public let firstName : String
	/// Last name of the Uber user.
	@objc public let lastName : String
	/// Email address of the Uber user.
	@objc public let email : String
	/// Image URL of the Uber user.
	@objc public let imageURL : NSURL?
	/// Promo code of the Uber user.
	@objc public let promoCode : String?
	/// Unique identifier of the Uber user.
	@objc public let UUID : String
	
	@objc public var description : String { get { return "Uber User \(firstName) \(lastName)" } }
	
	public required init?(JSON: [NSObject: AnyObject])
	{
		guard let firstName = JSON["first_name"] as? String, let lastName = JSON["last_name"] as? String, let email = JSON["email"] as? String, let UUID = JSON["uuid"] as? String
		else
		{
			self.firstName = ""
			self.lastName = ""
			self.email = ""
			self.imageURL = nil
			self.promoCode = nil
			self.UUID = ""
			return nil
		}
		
		self.firstName = firstName
		self.lastName = lastName
		self.email = email
		self.UUID = UUID
		
		if let URL = JSON["picture"] as? String
		{
			imageURL = NSURL(string: URL)
		}
		else
		{
			imageURL = nil
		}
		promoCode = JSON["promo_code"] as? String
	}
}