//
//  UberSDKiOSTests.swift
//  UberSDKiOSTests
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import UIKit
import XCTest

class UberSDKiOSTests: XCTestCase {
    
	var manager : UberManager!
	override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		manager = UberManager(delegate: self)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        XCTAssert(true, "Pass")
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
    
}
extension UberSDKiOSTests : UberManagerDelegate
{
	var applicationName: String { get { return "CocoaSDK" } }
	var clientID : String { get { return "DUf5ZDdiJlrhLvFIljaiHUF5n4RNdhTA" } }
	var clientSecret: String { get { return "" } }
	var serverToken : String { get { return "hNsUcO5PW5jbofJ_atHhlt9fZ7SoEJuDrB1zZ22J" } }
	var redirectURI : String { get { return "https://localhost:8000" } }
	var baseURL : UberBaseURL { get { return .SandboxAPI } }
}
