//
//  UberProductTestCase.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 25/07/15.
//
//

import XCTest
@testable import UberiOSSDK

class UberProductTestCase: XCTestCase
{

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	//MARK: - Asynchronous Testing
	func testAsynchronousProductFetching()
	{
		let productCompletion = expectationWithDescription("Products found")
		manager.fetchProductsForLocation(latitude: startLatitude, longitude: startLongitude, completionBlock: { products in
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			products.map {(product) in XCTAssertTrue(self.validProduct(product), "Invalid product found for uber product: \(product)") }
			print(products.map { $0.productID })
			productCompletion.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\nWith Response: \(error.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousProductFetchingUsingCoreLocation()
	{
		let productCLCompletion = expectationWithDescription("Products found")
		
		manager.fetchProductsForLocation(endLocation, completionBlock: { products in
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			products.map {(product) in XCTAssertTrue(self.validProduct(product), "Invalid product found for uber product: \(product)") }
			productCLCompletion.fulfill()
			}, errorHandler: { error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching products. Recieved: \(error)\n\nWith Response: \(error.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
	func testAsynchronousProductFetchingFailure()
	{
		let productCompletion = expectationWithDescription("Products found")
		manager.fetchProductsForLocation(latitude: badLatitude, longitude: badLongitude, completionBlock: { products in
			XCTAssertEqual(products.count, 0, "We expected 0 products for the given location.")
			products.map {(product) in XCTAssertTrue(self.validProduct(product), "Invalid product found for uber product: \(product)") }
			productCompletion.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error.isRepresentingNSError)
				productCompletion.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousProductFethchingUsingCoreLocationFailure()
	{
		let productCLCompletion = expectationWithDescription("Products found")
		
		manager.fetchProductsForLocation(badLocation, completionBlock: { products in
			XCTAssertEqual(products.count, 0, "We expected 0 products for the given location.")
			products.map {(product) in XCTAssertTrue(self.validProduct(product), "Invalid product found for uber product: \(product)") }
			productCLCompletion.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error.isRepresentingNSError)
				productCLCompletion.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
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

}
