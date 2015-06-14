//
//  UberPromotion.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation
/**
*  The Promotions endpoint returns information about the promotion that will be available to a new user based on their activity's location. These promotions do not apply for existing users.
*/
@objc public final class UberPromotion : CustomStringConvertible, JSONCreateable
{
	/// A localized string we recommend to use when offering the promotion to users.
	@objc public let displayText : String
	/// The value of the promotion that is available to a user in this location in the local currency.
	@objc public let value: String
	/// The type of Promotion as defined by the Uber API
	@objc public let type : UberPromotionType
	
	@objc public var description: String { get { return displayText } }
		
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
		return nil
	}
}