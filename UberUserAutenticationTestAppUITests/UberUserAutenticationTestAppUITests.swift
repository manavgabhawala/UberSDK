//
//  UberUserAutenticationTestAppUITests.swift
//  UberUserAutenticationTestAppUITests
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Foundation
import XCTest
@testable import UberiOSSDK

class UberUserAutenticationTestAppUITests: XCTestCase {
	
	
    override func setUp()
	{
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = true
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
	func testUserLogout()
	{
		let expectation = expectationWithDescription("Logged out")

		manager.logUberUserOut(completionBlock: {
			XCTAssertFalse(manager.userAuthenticator.authenticated())
			expectation.fulfill()
			}, errorHandler: { error in
				XCTAssertNotNil(error)
				XCTFail("We should be able to log the user out.")
		})
		waitForExpectationsWithTimeout(20.0, handler: nil)
	}
	
    func testUserAuthentication()
	{
		let app = XCUIApplication()
		let emailAddressTextField = app.textFields["Email Address"]
		if manager.userAuthenticator.authenticated()
		{
			return
		}
		if (!emailAddressTextField.exists && !manager.userAuthenticator.authenticated())
		{
			sleep(6)
		}
		
		if manager.userAuthenticator.authenticated()
		{
			// Test passed without even logging in.
			return
		}
		
		emailAddressTextField.tap()
		sleep(1)
		emailAddressTextField.typeText("manav1907@gmail.com")
		
		let xcuiSecureTextField = app.textFields["_XCUI:Secure"]
		xcuiSecureTextField.tap()
		sleep(1)
		xcuiSecureTextField.typeText(password)
		app.buttons["SIGN IN"].tap()
		sleep(3)
		app.buttons["ALLOW"].tap()
		sleep(20)
		XCTAssertTrue(manager.userAuthenticator.authenticated(), "We should now be able to add the request.")
    }
}
