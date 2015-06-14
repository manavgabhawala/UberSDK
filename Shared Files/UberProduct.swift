//
//  UberProduct.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

/**
The Products endpoint returns information about the Uber products offered at a given location. The response includes the display name and other details about each product, and lists the products in the proper display order.
*/
@objc public final class UberProduct : CustomStringConvertible, JSONCreateable, UberObjectHasImage
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



