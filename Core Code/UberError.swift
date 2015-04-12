//
//  UberError.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/12/15.
//
//

import Foundation
/**
A wrapper around an UberError that gets sent as JSON
*/
@objc public class UberError : Printable, DebugPrintable, JSONCreateable
{
	/// Human readable message which corresponds to the client error.
	@objc let errorMessage : String
	/// Underscored delimited string.
	@objc let code : String
	/// A hash of field names that have validations. This has a value of an array with member strings that describe the specific validation error.
	@objc let fields : [NSObject : AnyObject]?
	
	@objc public var description : String { get { return errorMessage } }
	@objc public var debugDescription : String { get { return description } }
	
	init(code: String, message: String, fields: [NSObject: AnyObject]?)
	{
		self.code = code
		errorMessage = message
		self.fields = fields
	}
	
	public convenience required init?(JSON: [NSObject : AnyObject])
	{
		if let code = JSON["code"] as? String
		{
			self.init(code: code, message: JSON["message"] as? String ?? "", fields: JSON["fields"] as? [NSObject : AnyObject])
			return
		}
		self.init(code: "", message: "", fields: nil)
		return nil
	}
	internal convenience init?(JSONData: NSData?)
	{
		if let JSONData = JSONData
		{
			var error : NSError?
			if let JSON = NSJSONSerialization.JSONObjectWithData(JSONData, options: nil, error: &error) as? [NSObject: AnyObject]
			{
				self.init(JSON: JSON)
				if self.code.isEmpty
				{
					return nil
				}
				return
			}
			uberLog("Error parsing JSON.")
			uberLog(error)
		}
		self.init(code: "", message: "", fields: nil)
		return nil
	}
}