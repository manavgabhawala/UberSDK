//
//  CallbackTypes.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation
import CoreGraphics
// MARK: - The callback blocks.
public typealias UberSuccessBlock = () -> Void
public typealias UberErrorHandler =  (UberError?) -> Void
public typealias UberProductSuccessBlock = ([UberProduct]) -> Void
public typealias UberSingleProductSuccessBlock = (UberProduct) -> Void
public typealias UberPriceEstimateSuccessBlock = ([UberPriceEstimate]) -> Void
public typealias UberTimeEstimateSuccessBlock = ([UberTimeEstimate]) -> Void
public typealias UberPromotionSuccessBlock = (UberPromotion) -> Void
public typealias UberActivitySuccessCallback = ([UberActivity], offset: Int, limit: Int, count: Int) -> Void
public typealias UberAllActivitySuccessCallback = ([UberActivity]) -> Void
public typealias UberUserSuccess = (UberUser) -> Void
public typealias UberRequestSuccessBlock = (UberRequest) -> Void
public typealias UberMapSuccessBlock = (UberRequest.Map) -> Void

// MARK: - Important internal protocols that allow for Generics.
internal protocol UberObjectHasImage
{
	var imageURL : NSURL? { get }
}

internal protocol JSONCreateable
{
	init?(JSON: [NSObject: AnyObject])
}
extension JSONCreateable
{
	init?(JSONData: NSData?)
	{
		guard let data = JSONData else { return nil }
		do
		{
			guard let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSObject: AnyObject]
				else { return nil }
			Self.init(JSON: JSON)
		}
		catch
		{
			return nil
		}
	}
	init?(JSON: [NSObject: AnyObject]?)
	{
		guard let JSON = JSON else { return nil }
		Self.init(JSON: JSON)
	}
}
internal protocol Viewable
{
	func addSubview(subview: Self)
	var frame: CGRect { get }
}


// MARK: - Custom Error For The SDK.
/**
A wrapper around an UberError that gets sent as JSON. It is a subclass of NSError so it may also be a wrapper around the NSError. Inspect the isRepresentingNSError property to determine whether to handle this as an error that Uber provided or an NSError.
*/
@objc public class UberError : NSError, JSONCreateable
{
	/// Human readable message which corresponds to the client error.
	@objc public let errorMessage : String
	/// Underscored delimited string.
	@objc public let errorCode : String
	/// A hash of field names that have validations. This has a value of an array with member strings that describe the specific validation error.
	@objc public let fields : [NSObject : AnyObject]?
	/// Use this property to determine whether the error is representing an NSError or an error generated from the Uber servers.
	@objc public let isRepresentingNSError: Bool
	
	/// An optional URL response, will be populated if available to help for debugging purposes.
	@objc public var response: NSURLResponse?
	
	@objc public override var description : String { get { return errorMessage } }
	

	internal let errorResponse : Int?
	
	internal let JSON : [NSObject : AnyObject]?

	init(code: String, message: String, fields: [NSObject: AnyObject]?, response: NSURLResponse?, errorResponse: Int?, JSON: [NSObject: AnyObject])
	{
		self.errorCode = code
		errorMessage = message
		self.fields = fields
		self.isRepresentingNSError = false
		self.response = response
		self.errorResponse = errorResponse
		if let _ = errorResponse
		{
			self.JSON = JSON
		}
		else
		{
			self.JSON = nil
		}
		super.init(domain: message, code: 1, userInfo: fields)
		
	}
	
	init(error: NSError, response: NSURLResponse? = nil)
	{
		errorCode = "\(error.code)"
		errorMessage = error.localizedDescription
		fields = error.userInfo
		self.isRepresentingNSError = true
		self.response = response
		self.errorResponse = nil
		self.JSON = nil
		super.init(domain: error.domain, code: error.code, userInfo: error.userInfo)
	}
	
	@objc(initWithNullableError:andResponse:)
	convenience init?(error: NSError?, response: NSURLResponse? = nil)
	{
		guard let error = error else { return nil }
		self.init(error: error, response: response)
	}
	
	public convenience init?(JSON: [NSObject : AnyObject], response: NSURLResponse?)
	{
		if let code = JSON["code"] as? String
		{
			self.init(code: code, message: JSON["message"] as? String ?? JSON["title"] as? String ?? "", fields: JSON["fields"] as? [NSObject : AnyObject], response: response, errorResponse: JSON["status"] as? Int, JSON: JSON)
			return
		}
		return nil
	}
	
	public convenience required init?(JSON: [NSObject : AnyObject])
	{
		self.init(JSON: JSON, response: nil)
	}
	
	public convenience init?(JSONData: NSData?, response: NSURLResponse?)
	{
		guard let data = JSONData else { return nil }
		do
		{
			guard let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [NSObject: AnyObject]
				else { return nil }
			self.init(JSON: JSON, response: response)
		}
		catch
		{
			return nil
		}
	}
	required public init?(coder aDecoder: NSCoder)
	{
		self.errorMessage = ""
		self.errorCode = ""
		self.fields = nil
		self.response = nil
		self.isRepresentingNSError = true
		self.errorResponse = nil
		self.JSON = nil
		super.init(coder: aDecoder)
	}
}
/*
internal class UberRequestError : UberError
{
	
	
	
	public override convenience required init?(JSON: [NSObject : AnyObject])
	{
		self.init(JSON: JSON, response: nil)
	}
	public override init?(JSON: [NSObject : AnyObject], response: NSURLResponse?)
	{
		self.JSON = JSON
		guard let responseCode = JSON["status"] as? Int, let code = JSON["code"] as? String, let description = JSON["title"] as? String
			else { errorResponse = 0; super.init(code: "", message: "", fields: nil,
				response: nil);
				return nil }
		errorResponse = responseCode
		super.init(code: code, message: description, fields: nil, response: response)
	}
	required override public init?(coder aDecoder: NSCoder)
	{
		errorResponse = 0
		JSON = [NSObject: AnyObject]()
		super.init(coder: aDecoder)
	}
}*/
