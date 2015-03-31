//
//  GenericExtensions.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

public var uberLogMode = true
func uberLog<T>(item: T)
{
	if uberLogMode
	{
		println("Uber API Log: \(item)\n")
	}
	
}
func uberLog<T>(item: T?)
{
	if let item = item where uberLogMode
	{
		println("Uber API Log: \(item)\n")
	}
	
}