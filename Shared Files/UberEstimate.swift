//
//  UberEstimate.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

@objc public class UberEstimate: JSONCreateable, CustomStringConvertible, CustomDebugStringConvertible
{
	/// Unique identifier representing a specific product for a given latitude & longitude. For example, uberX in San Francisco will have a different product_id than uberX in Los Angeles.
	@objc public let productID: String
	/// Display name of product.
	@objc public let productDisplayName: String
	
	@objc public var description : String { get { return productDisplayName } }
	@objc public var debugDescription : String { get { return description } }
	
	public required init?(JSON: [NSObject : AnyObject])
	{
		guard let id = JSON["product_id"] as? String, let displayName = JSON["display_name"] as? String
		else
		{
			productID = ""
			productDisplayName = ""
			return nil
		}
		productID = id
		productDisplayName = displayName
	}
}

