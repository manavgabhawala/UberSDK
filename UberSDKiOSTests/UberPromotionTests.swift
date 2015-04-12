//
//  UberPromotionTests.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 4/8/15.
//
//

import Foundation
import CoreLocation
import XCTest

private func validPromotion(promotion: UberPromotion?) -> Bool
{
	if promotion == nil
	{
		return true
	}
	if (promotion!.displayText.isEmpty || promotion!.value.isEmpty || promotion!.type == .Unknown)
	{
		return false
	}
	return true
}

class UberPromotionTests: XCTestCase
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
	
	func testAsynchronousPromotionFetching()
	{
		let promotionCompletion = expectationWithDescription("Price Estimates found")
		var response : NSURLResponse?
		var error : NSError?
		self.manager.fetchPromotionsForLocations(startLatitude: self.startLatitude, startLongitude: self.startLongitude, endLatitude: self.endLatitude, endLongitude: self.endLongitude,  completionBlock: {
			println("We found an Uber promotion: \($0)")
			XCTAssertTrue(validPromotion($0), "Invalid product found for uber promotion: \($0)")
			promotionCompletion.fulfill()
			} , errorHandler: {(_, _) in  XCTAssertFalse(false, "We should not reach the error handler.") })
		waitForExpectationsWithTimeout(60.0, handler: nil)
	}
}