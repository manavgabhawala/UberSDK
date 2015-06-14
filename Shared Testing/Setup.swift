//
//  Setup.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/14/15.
//
//

import Foundation
import CoreLocation
//import UberiOSSDK

SET THESE VALUES AS NEEDED TO RUN TESTS.
// MARK: Globals
class Delegate : NSObject, UberManagerDelegate
{
	var applicationName: String { get { return "APP NAME" } }
	var clientID : String { get { return "ID" } }
	var clientSecret: String { get { return "SECRET" } }
	var serverToken : String { get { return "SERVER TOKEN" } }
	var redirectURI : String { get { return "REDIRECT URI" } }
	var baseURL : UberBaseURL { get { return .SandboxAPI } }
	var scopes : [Int] { get { return [ UberScopes.Profile.rawValue, UberScopes.Request.rawValue, UberScopes.History.rawValue ] } }
	var surgeConfirmationRedirectURI : String { return redirectURI /* Change to custom if required */ }
}

let manager = UberManager(delegate: Delegate())

//MARK: - Locations
let startLatitude = 37.7759792
let startLongitude = -122.41823
let startLocation = CLLocation(latitude: startLatitude, longitude: startLongitude)

let endLatitude = 40.7439945
let endLongitude = -74.006194
let endLocation = CLLocation(latitude: endLatitude, longitude: endLongitude)

let badLatitude = 0.0
let badLongitude = 0.0
let badLocation = CLLocation(latitude: badLatitude, longitude: badLongitude)

let closeToStartLatitude = 37.7789792
let closeToStartLongitude = -122.31823
let closeToStartLocation = CLLocation(latitude: closeToStartLatitude, longitude: closeToStartLongitude)

// To test authentication and stuff.
let user = "EMAIL ID OF UBER USER"
let password = "PASSWORD OF UBER USER"
