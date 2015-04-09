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
	func testSynchronousPromotionFetching()
	{
		var response : NSURLResponse?
		var error : NSError?
		let promotion = self.manager.synchronouslyFetchPromotionsForLocation(startLatitude: self.startLatitude, startLongitude: self.startLongitude, response: &response, error: &error)
		XCTAssertNil(error, "Fatal error occured. We expected no errors when fetching a promotion. Recieved: \(error)\n\nWith response: \(response)\n")
		//XCTAssertNotNil(promotion, "Fatal error occured. We expected a promotion to be returned after fetching promotions. Recieved nil as products.")
		if let promo = promotion
		{
			println("We found an Uber promotion: \(promo)")
		}
		XCTAssertTrue(validPromotion(promotion), "Invalid product found for uber promotion: \(promotion)")
		
	}
}