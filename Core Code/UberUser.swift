//
//  UberUser.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

public typealias UberUserSuccess = (UberUser) -> Void

public class UberUser : Printable, DebugPrintable, JSONCreateable, UberObjectHasImage
{
	/// First name of the Uber user.
	public let firstName : String
	/// Last name of the Uber user.
	public let lastName : String
	/// Email address of the Uber user.
	public let email : String
	/// Image URL of the Uber user.
	public let imageURL : NSURL?
	/// Promo code of the Uber user.
	public let promoCode : String
	/// Unique identifier of the Uber user.
	public let UUID : String
	
	public var description : String { get { return "Uber User: \(firstName) \(lastName)" } }
	public var debugDescription : String { get { return description } }
	
	private init?(firstName: String?, lastName : String?, email : String?, imageURL: String?, promoCode: String?, UUID: String?)
	{
		if let firstName = firstName, let lastName = lastName, let email = email, let promoCode = promoCode, let UUID = UUID
		{
			self.firstName = firstName
			self.lastName = lastName
			self.email = email
			if let URL = imageURL
			{
				self.imageURL = NSURL(string: URL)
			}
			else
			{
				self.imageURL = nil
			}
			self.promoCode = promoCode
			self.UUID = UUID
			return
		}
		else
		{
			self.firstName = ""
			self.lastName = ""
			self.email = ""
			self.imageURL = NSURL(string: "")!
			self.promoCode = ""
			self.UUID = ""
			return nil
		}
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		self.init(firstName: JSON["first_name"] as? String, lastName: JSON["last_name"] as? String, email: JSON["email"] as? String, imageURL: JSON["picture"] as? String, promoCode: JSON["promo_code"] as? String, UUID: JSON["uuid"] as? String)
		if UUID.isEmpty
		{
			return nil
		}
	}
}