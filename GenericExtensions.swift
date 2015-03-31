//
//  GenericExtensions.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
/// Change this variable to false in order to stop the Uber SDK from printing things to the console

public var uberLogMode = true
/**
A generic printer for non-nil data that gets printed to the console.

:param: item The item to print.
*/
func uberLog<T>(item: T)
{
	if uberLogMode
	{
		println("> Uber API Log:\t \(item)\n")
	}
}
/**
A generic printer for nil data. It will only get printed to the console if the data passed in is non-nil.

:param: item The optional data to print.
*/
func uberLog<T>(item: T?)
{
	if let item = item where uberLogMode
	{
		println("Uber API Log: \(item)\n")
	}
	
}