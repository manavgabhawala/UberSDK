//
//  UberSDKProductsTests.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation

import UIKit
import CoreLocation
import XCTest

class UberSDKProductsTests: XCTestCase
{
	var manager : UberManager!
	let startLatitude = 37.7759792
	let startLongitude = -122.41823
	let endLatitude = 40.7439945
	let endLongitude = -74.006194
	
	override func setUp()
	{
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
		manager = UberManager(delegate: sharedDelegate)
	}
	override func tearDown()
	{
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	func testSynchronousProductFetching()
	{
		self.measureBlock
			{
				var response: NSURLResponse?
				var error: NSError?
				let products = self.manager.synchronouslyFetchProducts(latitude: self.startLatitude, longitude: self.startLongitude, response: &response, error: &error)
				XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith response: \(response)\n")
				XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
				println("We found Uber products: \(products!)")
				XCTAssertGreaterThan(products!.count, 0, "We expected at least one product for the given location.")
				
		}
	}
	func testSynchronousProductFetchingUsingCoreLocation()
	{
		self.measureBlock
			{
				var response: NSURLResponse?
				var error: NSError?
				let products = self.manager.synchronouslyFetchProducts(location: CLLocation(latitude: self.endLatitude, longitude: self.endLongitude), response: &response, error: &error)
				XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\n")
				XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
				println("We found Uber products: \(products!)")
				XCTAssertGreaterThan(products!.count, 0, "We expected at least one product for the given location.")
		}
	}
	
	func testAsynchronousProductFetching()
	{
		let productCompletion = self.expectationWithDescription("Products found")
		var response: NSURLResponse?
		var error: NSError?
		self.manager.asynchronouslyFetchProducts(latitude: self.startLatitude, longitude: self.startLongitude, completionBlock: {(products) in
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			println("We found Uber products: \(products)")
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			productCompletion.fulfill()
			}, errorHandler: {(response, error) in
				XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousProductFetchingUsingCoreLocation()
	{
		let productCLCompletion = self.expectationWithDescription("Products found")
		var response: NSURLResponse?
		var error: NSError?
		self.manager.asynchronouslyFetchProducts(location: CLLocation(latitude: self.endLatitude, longitude: self.endLongitude), completionBlock: {(products) in
			println("We found Uber products: \(products)")
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			//XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			productCLCompletion.fulfill()
			}, errorHandler: {(response, error) in
				XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
}