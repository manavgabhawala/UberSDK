//
//  UberProduct.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/30/15.
//
//

import Foundation
import UIKit

public typealias UberProductSuccessBlock = ([UberProduct]) -> Void
public typealias UberProductImageDownloadedBlock = (UberProduct) -> Void

public class UberProduct : Printable, DebugPrintable
{
	var productID: String
	var name: String
	var imageURL : NSURL
	var productDescription: String
	var capacity : Int
	
	var image: UIImage?
	
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
	public func downloadImageInBackground(successCallbackBlock success: UberProductImageDownloadedBlock?, andFailureCallbackBlock failure: UberErrorHandler?)
	{
		let request = NSURLRequest(URL: imageURL)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			if error == nil
			{
				if let image = UIImage(data: data)
				{
					self.image = image
					success?(self)
				}
				failure?(response, error)
			}
			else
			{
				failure?(response, error)
			}
		})
	}
}