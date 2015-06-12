//
//  UberProduct.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

/**
This class represents an UberProduct. It contains all the data recieved from the end point in this wrapper class for the UberProduct.
*/
@objc public final class UberProduct : CustomStringConvertible, CustomDebugStringConvertible, JSONCreateable, UberObjectHasImage
{
	/// Unique identifier representing a specific product for a given latitude & longitude.
	@objc public let productID: String
	/// Display name of product.
	@objc public let name: String
	/// Image URL representing the product. Depending on the platform you are using you can ask the UberProduct class to download the image `asynchronously` for you too.
	@objc public let imageURL : NSURL?
	/// Description of product.
	@objc public let productDescription: String
	/// Capacity of product. For example, 4 people.
	@objc public let capacity : Int
	/// The basic price details (not including any surge pricing adjustments). If null, the price is a metered fare such as a taxi service.
	@objc public var priceDetails : UberPriceDetails?
	
	@objc public var description : String { get { return "\(name): \(productDescription)" } }
	@objc public var debugDescription : String { get { return description } }
	
	private init?(productID: String? = nil, name: String? = nil, productDescription: String? = nil, capacity: Int? = nil, imageURL: String? = nil)
	{
		
		guard let id = productID, let name = name, let description = productDescription, let capacity = capacity
			else
		{
			self.productID = ""; self.name = ""; self.productDescription = ""; self.capacity = 0; self.imageURL = nil
			return nil
		}
		self.productID = id
		self.name = name
		self.productDescription = description
		self.capacity = capacity
		if let URL = imageURL
		{
			self.imageURL = NSURL(string: URL)
		}
		else
		{
			self.imageURL = nil
		}
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		self.init(productID: JSON["product_id"] as? String, name: JSON["display_name"] as? String, productDescription: JSON["description"] as? String, capacity: JSON["capacity"] as? Int, imageURL: JSON["image"] as? String)
		if self.productID.isEmpty
		{
			return nil
		}
		self.priceDetails = UberPriceDetails(JSON: JSON["price_details"] as? [NSObject: AnyObject])
	}
}

/**
This class represents the PriceDetails object associated with the Products endpoint.
*/
@objc public final class UberPriceDetails : JSONCreateable
{
	/// The base price.
	@objc public let base : Float
	/// The minimum price of a trip.
	@objc public let minimum : Float
	/// The charge per minute (if applicable for the product type).
	public let costPerMinute : Float?
	/// The charge per distance unit (if applicable for the product type).
	public let costPerDistance : Float?
	/// The unit of distance used to calculate the fare (either mile or km).
	@objc public let distanceUnit: String
	/// The fee if a rider cancels the trip after the grace period.
	@objc public let cancellationFee : Float
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	@objc public let currencyCode : String
	/// Array containing additional fees added to the price of a product.
	@objc public let serviceFees : [UberServiceFees]
	
	private init(base: Float, minimum: Float, costPerMinute: Float?, costPerDistance: Float?, distanceUnit: String, cancellationFee: Float, currencyCode: String, serviceFees: [UberServiceFees])
	{
		self.base = base
		self.minimum = minimum
		self.costPerMinute = costPerMinute
		self.costPerDistance = costPerDistance
		self.distanceUnit = distanceUnit
		self.cancellationFee = cancellationFee
		self.currencyCode = currencyCode
		self.serviceFees = serviceFees
	}
	public required convenience init?(JSON: [NSObject: AnyObject])
	{
		if let base = JSON["base"] as? Float, let minimum = JSON["minimum"] as? Float, let distanceUnit = JSON["distance_unit"] as? String, let cancellationFee = JSON["cancellation_fee"] as? Float, let currencyCode = JSON["currency_code"] as? String, let serviceFees = JSON["service_fees"] as? [[NSObject: AnyObject]]
		{
			self.init(base: base, minimum: minimum, costPerMinute: JSON["cost_per_minute"] as? Float, costPerDistance: JSON["cost_per_distance"] as? Float, distanceUnit: distanceUnit, cancellationFee: cancellationFee, currencyCode: currencyCode, serviceFees: UberServiceFees.serviceFeesFromJSON(serviceFees))
			return
		}
		return nil
	}
	
	@objc(initWithNullableJSON:)
	public required convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			self.init(JSON: JSON)
			return
		}
		return nil
	}
}

/**
This class reprsents the Service Fees object that is served as an array to the `UberPriceDetails` object from the Uber API.
*/
@objc public final class UberServiceFees
{
	/// The name of the service fee.
	@objc public let name : String
	/// The amount of the service fee.
	@objc public let fee : Float
	
	private init(name: String, fee: Float)
	{
		self.name = name
		self.fee = fee
	}
	private class func serviceFeesFromJSON(JSON: [[NSObject: AnyObject]]) -> [UberServiceFees]
	{
		var serviceFees = [UberServiceFees]()
		for object in JSON
		{
			if let name = object["name"] as? String, let fee = object["fee"] as? Float
			{
				serviceFees.append(UberServiceFees(name: name, fee: fee))
			}
		}
		return serviceFees
	}
}
