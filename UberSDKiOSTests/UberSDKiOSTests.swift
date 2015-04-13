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

class Delegate : NSObject, UberManagerDelegate
{
	var applicationName: String { get { return "CocoaSDK" } }
	var clientID : String { get { return "DUf5ZDdiJlrhLvFIljaiHUF5n4RNdhTA" } }
	var clientSecret: String { get { return "" } }
	var serverToken : String { get { return "" } }
	var redirectURI : String { get { return "https://localhost:8000" } }
	var baseURL : UberBaseURL { get { return .SandboxAPI } }
	var scopes : NSArray { get { return [ UberScopes.Profile.rawValue ] } }
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
		let manager = UberManager(applicationName: "", clientID: "", clientSecret: "", serverToken: "", redirectURI: "", baseURL: .SandboxAPI, scopes: [.Request, .Profile])
    }
    
    override func tearDown()
	{
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}

