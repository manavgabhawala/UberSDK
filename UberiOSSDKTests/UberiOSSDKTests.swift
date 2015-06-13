//
//  UberiOSSDKTests.swift
//  UberiOSSDKTests
//
//  Created by Manav Gabhawala on 6/11/15.
//
//

import XCTest

class UberiOSSDKTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testDownloadingImageOfProduct()
	{
		let imageCompletion = expectationWithDescription("Products found")
		manager.fetchProductsForLocation(latitude: startLatitude, longitude: startLongitude, completionBlock: { products in
			XCTAssertNotNil(products, "Fatal error occured. We expected products to be returned after fetching products. Recieved nil as products.")
			XCTAssertGreaterThan(products.count, 0, "We expected at least one product for the given location.")
			let product = products.first!
			product.downloadImage(completionBlock: {image, productReturned in
				XCTAssertNotNil(image)
				XCTAssertTrue(product === productReturned)
				imageCompletion.fulfill()
				}, errorHandler: { error in
					XCTAssertNotNil(error)
					XCTAssertTrue(error!.isRepresentingNSError)
					XCTFail("We should not have an error when downloading an image.")
			})
			
			}, errorHandler: {error in
				XCTFail("Fatal error occured. We expected no errors when fetching products. Recieved: \(error!)\nWith Response: \(error!.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
}
