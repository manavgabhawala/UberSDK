//
//  UberTimeEstimateTests.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation
import XCTest

class UberTimeEstimateTests : XCTestCase
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
	func testAsynchronousTimeEstimateFetching()
	{
		let timeEstimate = expectationWithDescription("Time Estimate found")
		manager.fetchTimeEstimateForLocation(startLatitude: startLatitude, startLongitude: startLongitude, completionBlock: { estimates in
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertGreaterThan(estimates.count, 0, "We expected at least one price estimate for the given location.")
			estimates.map {(estimate) in XCTAssertTrue(self.validTimeEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			timeEstimate.fulfill()
			}, errorHandler: {error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error!)\nWith Response: \(error!.response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousTimeEstimateFetchingUsingProductID()
	{
		let timeEstimateCLCompletion = expectationWithDescription("Time estimate found")
		let productID = "a1111c8c-c720-46c3-8534-2fcdd730040d"
		manager.fetchTimeEstimateForLocation(startLocation, productID: productID, completionBlock: { estimates in
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertGreaterThan(estimates.count, 0, "We expected only one time estimate for the given location and product.")
			
			XCTAssertTrue((estimates.map { $0.productID }).contains(productID), "The returned values must have the product we were looking for.")
			estimates.map { estimate in XCTAssertTrue(self.validTimeEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			timeEstimateCLCompletion.fulfill()
			
			}, errorHandler: { error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error!)\nWith Response: \(error!.response)\n")
		})
		waitForExpectationsWithTimeout(1000.0, handler: nil)
	}
	
	func testAsynchronousTimeEstimateFetchingError()
	{
		let timeEstimate = expectationWithDescription("Time Estimate found")
		manager.fetchTimeEstimateForLocation(startLatitude: badLatitude, startLongitude: badLongitude, completionBlock: { estimates in
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertEqual(estimates.count, 0, "We expected 0 price estimate for the given locations.")
			estimates.map {(estimate) in XCTAssertTrue(self.validTimeEstimate(estimate), "Invalid price estimate found for uber time estimate: \(estimate)") }
			timeEstimate.fulfill()
			}, errorHandler: { error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error!.isRepresentingNSError)
				XCTAssertNotNil(error!.fields)
				XCTAssertNotNil(error!.response)
				XCTAssertNotEqual(error!.errorCode, "")
				XCTAssertNotEqual(error!.errorMessage, "")
				timeEstimate.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousTimeEstimateFetchingErrorUsingCoreLocation()
	{
		let timeEstimateCLCompletion = expectationWithDescription("Time estimate found")
		manager.fetchTimeEstimateForLocation(badLocation, completionBlock: { estimates in
			XCTAssertNotNil(estimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			XCTAssertEqual(estimates.count, 0, "We expected 0 price estimate for the given locations.")
			estimates.map {(estimate) in XCTAssertTrue(self.validTimeEstimate(estimate), "Invalid price estimate found for uber time estimate: \(estimate)") }
			timeEstimateCLCompletion.fulfill()
			}, errorHandler: { error in
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTAssertFalse(error!.isRepresentingNSError)
				XCTAssertNotNil(error!.fields)
				XCTAssertNotNil(error!.response)
				XCTAssertNotEqual(error!.errorCode, "")
				XCTAssertNotEqual(error!.errorMessage, "")
				timeEstimateCLCompletion.fulfill()
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
	private func validTimeEstimate(estimate: UberTimeEstimate?) -> Bool
	{
		if estimate == nil
		{
			return false
		}
		if estimate!.productID.isEmpty || estimate!.productDisplayName.isEmpty || estimate!.estimate < 0
		{
			return false
		}
		if estimate!.ETD.compare(NSDate(timeIntervalSinceNow: 0)) == NSComparisonResult.OrderedAscending
		{
			return false
		}
		return true
	}
}