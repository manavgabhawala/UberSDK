//
//  UberPriceEstimateTestCase.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 25/07/15.
//
//

import XCTest
@testable import UberiOSSDK

class UberPriceEstimateTestCase: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

	//MARK: - Asynchronous Testing
	func testAsynchronousPriceEstimateFetching()
	{
		let priceEstimate = expectationWithDescription("Price Estimate found")
		manager.fetchPriceEstimateForTrip(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: closeToStartLatitude, endLongitude: closeToStartLongitude, completionBlock: { estimates in
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertGreaterThan(estimates.count, 0, "We expected at least one price estimate for the given location.")
			estimates.map {(estimate) in XCTAssertTrue(self.validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceEstimate.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\nWith Response: \(error.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousPriceEstimateFetchingUsingCoreLocation()
	{
		let priceEstimateCLCompletion = expectationWithDescription("Price estimate found")
		
		manager.fetchPriceEstimateForTrip(startLocation: startLocation, endLocation: closeToStartLocation, completionBlock: { estimates in
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertGreaterThan(estimates.count, 0, "We expected at least one price estimate for the given location.")
			estimates.map { estimate in XCTAssertTrue(self.validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceEstimateCLCompletion.fulfill()
			
			}, errorHandler: { error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\nWith Response: \(error.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
	func testAsynchronousPriceEstimateFetchingError()
	{
		let priceEstimate = expectationWithDescription("Price Estimate found")
		manager.fetchPriceEstimateForTrip(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, completionBlock: { estimates in
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertEqual(estimates.count, 0, "We expected 0 price estimate for the given locations.")
			estimates.map {(estimate) in XCTAssertTrue(self.validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceEstimate.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error.isRepresentingNSError)
				XCTAssertNotNil(error.fields)
				XCTAssertNotNil(error.response)
				XCTAssertNotEqual(error.errorCode, "")
				XCTAssertNotEqual(error.errorMessage, "")
				priceEstimate.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousPriceEstimateFetchingErrorUsingCoreLocation()
	{
		let priceEstimateCLCompletion = expectationWithDescription("Price estimate found")
		manager.fetchPriceEstimateForTrip(startLocation: startLocation, endLocation: endLocation, completionBlock: { estimates in
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertEqual(estimates.count, 0, "We expected 0 price estimate for the given locations.")
			estimates.map {(estimate) in XCTAssertTrue(self.validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceEstimateCLCompletion.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error.isRepresentingNSError)
				XCTAssertNotNil(error.fields)
				XCTAssertNotNil(error.response)
				XCTAssertNotEqual(error.errorCode, "")
				XCTAssertNotEqual(error.errorMessage, "")
				priceEstimateCLCompletion.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	private func validPriceEstimate(estimate: UberPriceEstimate?) -> Bool
	{
		if estimate == nil
		{
			return false
		}
		if estimate!.productID.isEmpty || estimate!.productDisplayName.isEmpty || estimate!.estimate.isEmpty || estimate!.currency.isEmpty ||  estimate!.highEstimate <= 0 || estimate!.lowEstimate <= 0 || estimate!.duration <= 0 || estimate!.distance <= 0 || estimate!.surgeMultiplier <= 0.0
		{
			return false
		}
		if estimate!.ETA.compare(NSDate(timeIntervalSinceNow: 0)) != NSComparisonResult.OrderedDescending
		{
			return false
		}
		return true
	}

}
