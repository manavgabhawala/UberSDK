//
//  UberProduct.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/30/15.
//
//

import Foundation

public typealias UberProductSuccessBlock = ([UberProduct]) -> Void
/**
*  This class represents an UberProduct. It contains all the data recieved from the end point in this wrapper class for the UberProduct.
*/
public class UberProduct : Printable, DebugPrintable
{
	/// The Product ID for the associated Uber product.
	public let productID: String
	/// A user displayable name for the Uber product.
	public let name: String
	/// A URL to an image of the product. Depending on the platform you are using you can ask the UberProduct class to download the image `asynchronously` for you too.
	public let imageURL : NSURL?
	/// A description of the Uber product.
	public let productDescription: String
	/// Capacity of product. For example, 4 people.
	public let capacity : Int
	/// The basic price details (not including any surge pricing adjustments). If null, the price is a metered fare such as a taxi service.
	public var priceDetails : UberPriceDetails?
	
	public var description : String
	{
		get
		{
			return "\(name): \(productDescription)"
		}
	}
	public var debugDescription : String
	{
		get
		{
			return description
		}
	}
	private init(productID: String, name: String, productDescription: String, capacity: Int, imageURL : String)
	{
		self.productID = productID
		self.name = name
		self.productDescription = productDescription
		self.imageURL = NSURL(string: imageURL)
		self.capacity = capacity
	}
	
	private convenience init?(productID: String? = nil, name: String? = nil, productDescription: String? = nil, capacity: Int? = nil, imageURL: String? = nil)
	{
		
		if let id = productID, let name = name, let description = productDescription, let capacity = capacity, let imageURL = imageURL
		{
			self.init(productID: id, name: name, productDescription: description, capacity: capacity, imageURL: imageURL)
			return
		}
		self.init(productID: "", name: "", productDescription: "", capacity: 0, imageURL: "")
		return nil
	}
	
	internal convenience init?(JSON: [NSObject: AnyObject])
	{
		self.init(productID: JSON["product_id"] as? String, name: JSON["display_name"] as? String, productDescription: JSON["description"] as? String, capacity: JSON["capacity"] as? Int, imageURL: JSON["image"] as? String)
		if self.productID.isEmpty
		{
			return nil
		}
		self.priceDetails = UberPriceDetails(JSON: JSON["price_details"] as? [NSObject: AnyObject])
	}
	
	/**
	Use this function to communicate with the Uber Product Endpoint. You can create an UberProduct wrapper using just the productID.
	
	:param: productID The productID with which to create a new UberProduct
	
	:returns: nil if the product could not be formed. An initialized UberProduct on successful creation of the wrapper object.
	
	*:warning:* Product IDs are different for different regions. Fetch all products for a location using the UberManager instance.
	*/
	public convenience init?(productID: String)
	{
		assert(sharedDelegate != nil, "You must initialize the UberManager using UberManager(delegate: UberManagerDelegate) initializer before being able to call methods on the Uber SDK.")
		let URL = "\(sharedDelegate.baseURL)/v1/products/\(productID)"
		let request = createRequestForURL(URL)
		var response : NSURLResponse?
		var error : NSError?
		if let data = NSURLConnection.sendSynchronousRequest(request, returningResponse: &response, error: &error)
		{
			if (error == nil)
			{
				if let JSON = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? [NSObject: AnyObject]
				{
					self.init(JSON: JSON)
				}
				else
				{
					uberLog("Error parsing returned JSON query.")
					self.init()
				}
			}
			else
			{
				uberLog("Error while fetching product with product id: \(productID).\n\nNSURLResponse: \(response)\n\nError: \(error)")
				self.init()
			}
		}
		else
		{
			uberLog("Error while fetching product with product id: \(productID).\n\nNSURLResponse: \(response)\n\nError: \(error)")
			self.init()
		}
		if productID != self.productID
		{
			uberLog("Failed to create product using product ID: \(productID). Returning nil.")
			return nil
		}
	}
}

/**
This class represents the PriceDetails object associated with the Products endpoint.
*/
public class UberPriceDetails
{
	/// The base price.
	public let base : Float
	/// The minimum price of a trip.
	public let minimum : Float
	/// The charge per minute (if applicable for the product type).
	public let costPerMinute : Float?
	/// The charge per distance unit (if applicable for the product type).
	public let costPerDistance : Float?
	/// The unit of distance used to calculate the fare (either mile or km).
	public let distanceUnit: String
	/// The fee if a rider cancels the trip after the grace period.
	public let cancellationFee : Float
	/// http://en.wikipedia.org/wiki/ISO_4217 ISO 4217 currency code.
	public let currencyCode : String
	/// Array containing additional fees added to the price of a product.
	public let serviceFees : [UberServiceFees]
	
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
	
	private convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			if let base = JSON["base"] as? Float, let minimum = JSON["minimum"] as? Float, let distanceUnit = JSON["distance_unit"] as? String, let cancellationFee = JSON["cancellation_fee"] as? Float, let currencyCode = JSON["currency_code"] as? String, let serviceFees = JSON["service_fees"] as? [[NSObject: AnyObject]]
			{
				self.init(base: base, minimum: minimum, costPerMinute: JSON["cost_per_minute"] as? Float, costPerDistance: JSON["cost_per_distance"] as? Float, distanceUnit: distanceUnit, cancellationFee: cancellationFee, currencyCode: currencyCode, serviceFees: UberServiceFees.serviceFeesFromJSON(serviceFees))
				return
			}
		}
		self.init(base: 0, minimum: 0, costPerMinute: nil, costPerDistance: nil, distanceUnit: "", cancellationFee: 0, currencyCode: "", serviceFees: [])
		return nil
	}
}
/**
This class reprsents the Service Fees object that is served as an array to the `UberPriceDetails` object from the Uber API.
*/
public class UberServiceFees
{
	/// The name of the service fee.
	public let name : String
	/// The amount of the service fee.
	public let fee : Float
	
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

