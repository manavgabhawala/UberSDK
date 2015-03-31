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
	
}