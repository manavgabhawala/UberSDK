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

private func validProduct(product: UberProduct?) -> Bool
{
	if product == nil
	{
		return false
	}
	if (product!.productID.isEmpty || product!.name.isEmpty || product!.capacity <= 0 || product!.productDescription.isEmpty || product!.imageURL == nil)
	{
		return false
	}
	if (product!.name != "uberT" && product!.name != "uberTAXI")
	{
		if (product!.priceDetails == nil)
		{
			return false
		}
	}
	return true
}

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
		manager = UberManager(delegate: sharedTestingDelegate)
	}
	override func tearDown()
	{
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	/*
	//MARK: - Synchronous Testing
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
			products!.map {(product) in XCTAssertTrue(validProduct(product), "Invalid product found for uber product: \(product)") }
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
			products!.map {(product) in XCTAssertTrue(validProduct(product), "Invalid product found for uber product: \(product)") }
		}
	}*/
	//MARK: - Asynchronous Testing
	func testAsynchronousProductFetching()
	{
		let productCompletion = expectationWithDescription("Products found")
		self.manager.fetchProductsForLocation(latitude: startLatitude, longitude: startLongitude, completionBlock: {(products) in
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			println("We found Uber products: \(products)")
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			products.map {(product) in XCTAssertTrue(validProduct(product), "Invalid product found for uber product: \(product)") }
			productCompletion.fulfill()
			}, errorHandler: {(response, error) in
				XCTAssertNotNil(response, "Response should not be nil in the error handler.")
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousProductFetchingUsingCoreLocation()
	{
		let productCLCompletion = expectationWithDescription("Products found")
		var response: NSURLResponse?
		var error: NSError?
		manager.fetchProductsForLocation(CLLocation(latitude: endLatitude, longitude: endLongitude), completionBlock: {(products) in
			println("We found Uber products: \(products)")
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			products.map {(product) in XCTAssertTrue(validProduct(product), "Invalid product found for uber product: \(product)") }
			productCLCompletion.fulfill()
			}, errorHandler: {(response, error) in
				XCTAssertNotNil(response, "Response should not be nil in the error handler.")
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	/*
	//MARK: - iOS Platform Specific Testing
	func testDownloadImage()
	{
		let imageDownloaded = expectationWithDescription("Image downloaded")
		var error: NSError?
		
		let product = self.manager.synchronouslyFetchProducts(latitude: self.startLatitude, longitude: self.startLongitude, response: nil, error: nil)?.first
		XCTAssertNotNil(product, "Failed to download image since the product could not be loaded from Uber.")
		product!.downloadImageInBackground(successCallbackBlock: {(product, image) in
			XCTAssertNotNil(product, "Product returned shouldn't be nil")
			XCTAssertTrue(validProduct(product), "Invalid product returned from the download image function.")
			XCTAssertNotNil(image, "Image downloaded should not be nil.")
			imageDownloaded.fulfill()
			}, andFailureCallbackBlock: {(response, error) in
				XCTAssertNotNil(response, "Response should not be nil in the error handler.")
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when downloading the image. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)

	}
*/
}