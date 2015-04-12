//
//  UberSDKPriceEstimateTests.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import CoreLocation
import XCTest

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

class UberSDKPriceEstimateTests: XCTestCase
{
	var manager : UberManager!

	let startLatitude = 42.280609
	let startLongitude = -83.731088

	let endLatitude = 42.279672
	let endLongitude = -83.748447
	
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
	func testSynchronousPriceEstimate()
	{
		self.measureBlock
		{
			var response: NSURLResponse?
			var error: NSError?
			let priceEstimates = self.manager.synchronouslyFetchPriceEstimateForTrip(startLatitude: self.startLatitude, startLongitude: self.startLongitude, endLatitude: self.endLatitude, endLongitude: self.endLongitude, response: &response, error: &error)
			XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\n\nWith response: \(response)\n")
			XCTAssertNotNil(priceEstimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			println("We found Uber price estimates: \(priceEstimates!)")
			XCTAssertGreaterThan(priceEstimates!.count, 0, "We expected at least one price estimate for the given trip.")
			priceEstimates!.map {(estimate) in XCTAssertTrue(validPriceEstimate(estimate), "Invalid price estimates found for uber price estimates: \(estimate)") }
		}
	}
	func testSynchronousPriceEstimateWithCoreLocation()
	{
		self.measureBlock
		{
			var response: NSURLResponse?
			var error: NSError?
			let priceEstimates = self.manager.synchronouslyFetchPriceEstimateForTrip(startLocation: CLLocation(latitude: self.startLatitude, longitude: self.startLongitude), endLocation: CLLocation(latitude: self.endLatitude, longitude: self.endLongitude), response: &response, error: &error)
			XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\n\nWith response: \(response)\n")
			XCTAssertNotNil(priceEstimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			println("We found Uber price estimates: \(priceEstimates!)")
			XCTAssertGreaterThan(priceEstimates!.count, 0, "We expected at least one price estimate for the given trip.")
			priceEstimates!.map {(estimate) in XCTAssertTrue(validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
		}
	}
	*/
	//MARK: - Asynchronous Testing
	func testAsynchronousPriceEstimate()
	{
		let priceCompletion = expectationWithDescription("Price Estimates found")
		manager.fetchPriceEstimateForTrip(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, completionBlock: {(priceEstimates) in
			XCTAssertNotNil(priceEstimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			println("We found Uber price estimates: \(priceEstimates)")
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertGreaterThan(priceEstimates.count, 0, "We expected at least one price estimate for the given location.")
			priceEstimates.map {(estimate) in XCTAssertTrue(validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceCompletion.fulfill()
			}, errorHandler: {(_, response, error) in
				XCTAssertNotNil(response, "Response should not be nil in the error handler.")
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	func testAsynchronousPriceEstimateWithCoreLocation()
	{
		let priceCompletion = expectationWithDescription("Price Estimates found")
		manager.fetchPriceEstimateForTrip(startLocation: CLLocation(latitude: endLatitude, longitude: endLongitude), endLocation: CLLocation(latitude: startLatitude, longitude: startLongitude), completionBlock: {(priceEstimates) in
			XCTAssertNotNil(priceEstimates, "Fatal error occured. We expected price estimates to be returned after fetching price estimates. Recieved nil as price estimates.")
			println("We found Uber price estimates: \(priceEstimates)")
			XCTAssertTrue(true, "Called the completion block successfully")
			XCTAssertGreaterThan(priceEstimates.count, 0, "We expected at least one price estimate for the given location.")
			priceEstimates.map {(estimate) in XCTAssertTrue(validPriceEstimate(estimate), "Invalid price estimate found for uber price estimate: \(estimate)") }
			priceCompletion.fulfill()
			}, errorHandler: {(_, response, error) in
				XCTAssertNotNil(response, "Response should not be nil in the error handler.")
				XCTAssertNotNil(error, "Error should not be nil in the error handler.")
				XCTFail("Fatal error occured. We expected no errors when fetching price estimates. Recieved: \(error)\n\nWith Response: \(response)\n")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
}