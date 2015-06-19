//
//  Enums.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/11/15.
//
//

import Foundation

/**
Use this enumeration to provide the scopes you wish to show the user when performing OAuth2 with the Uber API.
*/
@objc public enum UberScopes : Int, Any, CustomStringConvertible
{
	/// Access the basic profile information on a user's Uber account including their first name, email address, and profile picture.
	case Profile
	
	/// Pull trip data including times, product type, and city information of a user's historical pickups and drop-offs.
	case History
	
	/// Pull trip data including times and product type information of a user's historical pickups and drop-offs.
	case HistoryLite
	
	/// Make requests for Uber Products on behalf of users.
	case Request
	
	/// Get receipt details for Requests made by application.
	case RequestReceipt
	
	public var description : String
	{
		get
		{
			switch self
			{
			case .Profile:
				return "profile"
			case .HistoryLite:
				return "history_lite"
			case .Request:
				return "request"
			case .History:
				return "history"
			case .RequestReceipt:
				return "request_receipt"
			}
		}
	}
}

/**
This is an enumeration that allows you to choose between the ProductionAPI and the SandboxAPI.
*/
@objc public enum UberBaseURL : Int, CustomStringConvertible
{
	/// The Uber Production API provides real endpoints to the actual application and should be used in all release builds.
	case ProductionAPI
	/// The Uber API Sandbox provides development endpoints for testing the functionality of an application without making calls to the production Uber platform. All requests made to the Sandbox environment will be ephemeral.
	case SandboxAPI
	internal var URL: String
	{
		get
		{
			switch self
			{
			case .ProductionAPI:
				return "https://api.uber.com"
			case .SandboxAPI:
				return "https://sandbox-api.uber.com"
			}
		}
	}
	public var description : String {
		get
		{
			switch self
			{
			case .ProductionAPI:
				return "Production API"
			case .SandboxAPI:
				return "Sandbox API"
			}
		}
	}
}

internal enum HTTPMethod : String
{
	case Post = "POST"
	case Get = "GET"
	case Delete = "DELETE"
	case Put = "PUT"
}

/**
An enumeration of all the languages that Über supports.
*/
@objc public enum Language : Int, CustomStringConvertible
{
	/// Saudi Arabia
	case Arabic
	/// Germany
	case German
	/// United States
	case English
	/// France
	case French
	/// Italy
	case Italian
	/// Japan
	case Japanese
	/// Korea
	case Korean
	/// Malaysia
	case Malay
	/// Netherlands
	case Dutch
	/// Brazil
	case Portuguese
	/// Russia
	case Russian
	/// Sweden
	case Swedish
	/// Thailand
	case Thai
	/// Philippines
	case Tagalog
	/// China
	case Chinese1
	/// Taiwan
	case Chinese2
	public var description: String
	{
		get
		{
			switch self
			{
				/// Saudi Arabia
			case Arabic    : return "ar_SA"
				/// Germany
			case German    : return "de_DE"
				/// United States
			case English   : return "en_US"
				/// France
			case French    : return "fr_FR"
				/// Italy
			case Italian   : return "it_IT"
				/// Japan
			case Japanese  : return "ja_JP"
				/// Korea
			case Korean    : return "ko_KR"
				/// Malaysia
			case Malay     : return "ms_MY"
				/// Netherlands
			case Dutch     : return "nl_NL"
				/// Brazil
			case Portuguese: return "pt_BR"
				/// Russia
			case Russian   : return "ru_RU"
				/// Sweden
			case Swedish   : return "sv_SE"
				/// Thailand
			case Thai      : return "th_TH"
				/// Philippines
			case Tagalog   : return "tl_PH"
				/// China
			case Chinese1  : return "zh_CN"
				/// Taiwan
			case Chinese2  : return "zh_TW"
			}
		}
	}
}

/**
An enumeration of the possible Promotion Types.

- TripCredit:    Trip credit for the user.
- AccountCredit: Credit on the user's account.
- Unknown:       We do not understand the promotion type. The type will be saved as Unknown and the actual string representation will be printed to the console.
*/
@objc public enum UberPromotionType: Int, CustomStringConvertible
{
	/// Trip credit for the user.
	case TripCredit
	/// Credit on the user's account.
	case AccountCredit
	/// We do not understand the promotion type. The type will be saved as Unknown
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
			}
		}
	}
	
	internal static func create(string: String) -> UberPromotionType
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
		print("Unknown Promotion Type Recieved: \(string)")
		return .Unknown
	}
}


public enum UberActivityStatus : String
{
	case Completed = "completed"
	case Unknown = "Unknown"
}

public enum UberRequestStatus : String
{
	case Processing = "processing"
	case NoDriversAvailable = "no_drivers_available"
	case Accepted = "accepted"
	case Arriving = "arriving"
	case InProgress = "in_progress"
	case DriverCancelled = "driver_canceled"
	case RiderCancelled = "rider_canceled"
	case Completed = "completed"
	case Unknown = ""
}