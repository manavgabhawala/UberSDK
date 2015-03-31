//
//  UberProduct.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/30/15.
//
//

import Foundation

public typealias UberProductSuccessBlock = ([UberProduct]) -> Void

public class UberProduct : Printable, DebugPrintable
{
	var productID: String
	var name: String
	var imageURL : NSURL
	var productDescription: String
	var capacity : Int
	
	
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
	init(productID: String, name: String, productDescription: String, capacity: Int, imageURL : String)
	{
		self.productID = productID
		self.name = name
		self.productDescription = productDescription
		self.imageURL = NSURL(string: imageURL)!
		self.capacity = capacity
	}
	
	convenience init?(productID: String?, name: String?, productDescription: String?, capacity: Int?, imageURL: String?)
	{
		
		if let id = productID, let name = name, let description = productDescription, let capacity = capacity, let imageURL = imageURL
		{
			self.init(productID: id, name: name, productDescription: description, capacity: capacity, imageURL: imageURL)
			return
		}
		self.init(productID: "", name: "", productDescription: "", capacity: 0, imageURL: "")
		return nil
	}
	convenience init?(JSON: [NSObject: AnyObject])
	{
		self.init(productID: JSON["product_id"] as? String, name: JSON["display_name"] as? String, productDescription: JSON["description"] as? String, capacity: JSON["capacity"] as? Int, imageURL: JSON["image"] as? String)
		if self.productID.isEmpty
		{
			return nil
		}
	}
}