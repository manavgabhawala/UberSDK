//
//  UberUser.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

public typealias UberUserSuccess = (UberUser) -> Void

public class UberUser : Printable, DebugPrintable
{
	/// First name of the Uber user.
	public let firstName : String
	/// Last name of the Uber user.
	public let lastName : String
	/// Email address of the Uber user.
	public let email : String
	/// Image URL of the Uber user.
	public let imageURL : NSURL
	/// Promo code of the Uber user.
	public let promoCode : String
	/// Unique identifier of the Uber user.
	public let UUID : String
	
	public var description : String { get { return "Uber User: \(firstName) \(lastName)" } }
	public var debugDescription : String { get { return description } }
	
	private init?(firstName: String?, lastName : String?, email : String?, imageURL: String?, promoCode: String?, UUID: String?)
	{
		if let firstName = firstName, let lastName = lastName, let email = email, let imageURLString = imageURL, let URL = NSURL(string: imageURLString), let promoCode = promoCode, let UUID = UUID
		{
			self.firstName = firstName
			self.lastName = lastName
			self.email = email
			self.imageURL = URL
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
	private convenience init?(JSON: [NSObject: AnyObject])
	{
		self.init(firstName: JSON["first_name"] as? String, lastName: JSON["last_name"] as? String, email: JSON["email"] as? String, imageURL: JSON["picture"] as? String, promoCode: JSON["promo_code"] as? String, UUID: JSON["uuid"] as? String)
		if UUID.isEmpty
		{
			return nil
		}
	}
	
	class func createUserProfileSynchronously(response responsePointer: AutoreleasingUnsafeMutablePointer<NSURLResponse?>, error errorPointer: NSErrorPointer) -> UberUser?
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL)/v1/profile", requireUserAccessToken: true)
		var response : NSURLResponse?
		if responsePointer != nil
		{
			response = responsePointer.memory
		}
		var error : NSError?
		let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
		var JSONData : [NSObject : AnyObject]?
		var JSONError : NSError?
		if errorPointer != nil
		{
			error = errorPointer.memory
		}
		if let data = data
		{
			JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? [NSObject: AnyObject]
		}
		if JSONError != nil
		{
			error = JSONError
			return nil
		}
		if (error == nil)
		{
			if let JSON = JSONData
			{
				return UberUser(JSON: JSON)
			}
		}
		return nil
	}
	
	class func createUserProfileAsynchronously(success: UberUserSuccess?, failure: UberErrorHandler?)
	{
		let request = createRequestForURL("\(sharedDelegate.baseURL)/v1/profile", requireUserAccessToken: true)
		var response : NSURLResponse?
		var error : NSError?
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			var JSONError: NSError?
			if (error == nil)
			{
				if let JSONData = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &JSONError) as? [NSObject: AnyObject]
				{
					if let user = UberUser(JSON: JSONData)
					{
						success?(user)
						return
					}
					uberLog("Error parsing Promotion JSON. Please look at the console to see the JSON that got parsed.")
					failure?(response, JSONError)
				}
				else
				{
					uberLog("Error parsing Promotion JSON. Please look at the console to see the JSON that got parsed.")
					failure?(response, JSONError)
				}
			}
			else
			{
				failure?(response, error)
			}
		})
	}
}