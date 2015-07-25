//
//  UberServiceFees.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

/// This class reprsents the Service Fees object that is served as an array to the `UberPriceDetails` object from the Uber API.
@objc public final class UberServiceFees: NSObject
{
	/// The name of the service fee.
	@objc public let name : String
	/// The amount of the service fee.
	@objc public let fee : Float
	
	private init(name: String, fee: Float)
	{
		self.name = name
		self.fee = fee
		super.init()
	}
	
	internal class func serviceFeesFromJSON(JSON: [[NSObject: AnyObject]]) -> [UberServiceFees]
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
