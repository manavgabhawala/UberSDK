//
//  UberPriceDetails.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation

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
	/*
	@objc(initWithNullableJSON:)
	public required convenience init?(JSON: [NSObject: AnyObject]?)
	{
		if let JSON = JSON
		{
			self.init(JSON: JSON)
			return
		}
		return nil
	}*/
}