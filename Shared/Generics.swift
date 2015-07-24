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
	///  An initializer that allows for a native Swift `String` to be created using `NSData`
	///
	///  - parameter data:     The data with which to create the `String`
	///  - parameter encoding: The encoding with which to parse the data. This defaults to `NSUTF8StringEncoding` if no encoding is specified.
	///
	///  - returns: nil if the data passed was nil or if the `String` couldn't be formed using the encoding specified.
	internal init?(data: NSData?, encoding: NSStringEncoding = NSUTF8StringEncoding)
	{
		guard let data = data
			else
		{
			return nil
		}
		guard let str = NSString(data: data, encoding: encoding) as? String
			else
		{
			return nil
		}
		self.init(str)
	}
}

extension NSDate: Comparable
{}
public func < (lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedAscending
}
public func ==(lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedSame
}
public func > (lhs: NSDate, rhs: NSDate) -> Bool
{
	return lhs.compare(rhs) == .OrderedDescending
}
