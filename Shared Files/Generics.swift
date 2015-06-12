//
//  Generics.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation


extension String
{
	/**
	Create a swift type string with data.
	
	- param data     The data to parse into a string
	:param: encoding The encoding to use to decode the string. The default is NSUTF8StringEncoding
	
	- returns An initialized string.
	*/
	init?(data: NSData?, encoding: UInt = NSUTF8StringEncoding)
	{
		guard let data = data else { return nil }
		self = NSString(data: data, encoding: encoding) as! String
	}
}

extension NSDate : Comparable
{
	class var now : NSDate
	{
		get
		{
			return NSDate(timeIntervalSinceNow: 0)
		}
	}
}

public func ==(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedSame
}

public func <(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs)
		== 	.OrderedAscending
}
