//
//  UberSDKiOSTests.swift
//  UberSDKiOSTests
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import UIKit
import CoreLocation
import XCTest

@objc class Delegate : UberManagerDelegate
{
	@objc var applicationName: String { get { return "CocoaSDK" } }
	@objc var clientID : String { get { return "DUf5ZDdiJlrhLvFIljaiHUF5n4RNdhTA" } }
	@objc var clientSecret: String { get { return "" } }
	@objc var serverToken : String { get { return "" } }
	@objc var redirectURI : String { get { return "https://localhost:8000" } }
	@objc var baseURL : UberBaseURL { get { return .SandboxAPI } }
	@objc var scopes : NSArray { get { return [ UberScopes.Profile.rawValue ] } }
}

let sharedTestingDelegate = Delegate()

class UberSDKiOSTests: XCTestCase {
    
	var manager : UberManager!
	let startLatitude = 37.7759792
	let startLongitude = -122.41823
	let endLatitude = 40.7439945
	let endLongitude = -74.006194
	override func setUp()
	{
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
		
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

