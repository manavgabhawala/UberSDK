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
	public var productID: String
	/// A user displayable name for the Uber product.
	public var name: String
	/// A URL to an image of the product. Depending on the platform you are using you can ask the UberProduct class to download the image `asynchronously` for you too.
	public var imageURL : NSURL?
	/// A description of the Uber product.
	public var productDescription: String
	/// The maximum capacity of the product.
	public var capacity : Int
	
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