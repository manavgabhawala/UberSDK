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
@objc public enum UberPromotionType: Int, Printable, DebugPrintable
{
	case TripCredit
	case AccountCredit
	case Unknown
	
	public var description : String
		{
		get
		{
			switch self
			{
			case .TripCredit:
				return "Trip Credit"
			case .AccountCredit:
				return "Account Credit"
			case .Unknown:
				return "Undefined"
			default:
				assert(false, "We have an undefined enum type.")
				return ""
			}
		}
	}
	public var debugDescription : String { get { return description } }
	
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

@objc public class UberPromotion : Printable, DebugPrintable, JSONCreateable
{
	/// A localized string we recommend to use when offering the promotion to users.
	@objc public let displayText : String
	/// The value of the promotion that is available to a user in this location in the local currency.
	@objc public let value: String
	/// The type of Promotion as defined by the Uber API
	@objc public let type : UberPromotionType
	
	@objc public var description: String { get { return displayText } }
	
	@objc public var debugDescription: String { get { return description } }
	
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