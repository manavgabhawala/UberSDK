//
//  UberPromotion.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/7/15.
//
//

import Foundation
public typealias UberPromotionSuccessBlock = (UberPromotion) -> Void
/**
An enumeration of the possible Promotion Types.

- TripCredit:    Trip credit for the user.
- AccountCredit: Credit on the user's account.
- Unknown:       We do not understand the promotion type. The type will be saved as Unknown and the actual string representation will be printed to the console.
*/
public enum UberPromotionType
{
	case TripCredit
	case AccountCredit
	case Unknown
	
	private static func create(string: String) -> UberPromotionType
	{
		if string == "trip_credit"
		{
			return .TripCredit
		}
		else if string == "account_credit"
		{
			return .AccountCredit
		}
		else if string == ""
		{
			return .Unknown
		}
		uberLog("Unknown Promotion Type Recieved: \(string)")
		return .Unknown
	}
}

public class UberPromotion : Printable, DebugPrintable, JSONCreateable
{
	/// A localized string we recommend to use when offering the promotion to users.
	public let displayText : String
	/// The value of the promotion that is available to a user in this location in the local currency.
	public let value: String
	/// The type of Promotion as defined by the Uber API
	public let type : UberPromotionType
	
	public var description: String { get { return displayText } }
	
	public var debugDescription: String { get { return description } }
	
	private init(displayText : String, value : String, type: String)
	{
		self.displayText = displayText
		self.value = value
		self.type = UberPromotionType.create(type)
	}
	
	public convenience required init?(JSON: [NSObject: AnyObject])
	{
		if let text = JSON["display_text"] as? String, let value = JSON["localized_value"] as? String, let type = JSON["type"] as? String
		{
			self.init(displayText: text, value: value, type: type)
			return
		}
		self.init(displayText: "", value: "", type: "")
		return nil
	}
}