//
//  UberUserOAuth.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/30/15.
//
//

import Foundation


internal class UberUserOAuth : NSObject
{
	private var accessToken : String!
	private var refreshToken: String!
	private var expiration : NSDate!
	private var uberOAuthCredentialsLocation : String!
	private var successBlock : UberSuccessBlock?
	
	internal var errorHandler : UberErrorHandler?
	
	internal override init()
	{
		if let directory = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as? String
		{
			uberOAuthCredentialsLocation = "\(directory)/Authentication.plist"
			let fileManager = NSFileManager()
			if !fileManager.fileExistsAtPath(directory)
			{
				fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil, error: nil)
			}
			if !fileManager.fileExistsAtPath(uberOAuthCredentialsLocation)
			{
				fileManager.createFileAtPath(uberOAuthCredentialsLocation, contents: nil, attributes: nil)
			}
		}
		if let dictionary = NSDictionary(contentsOfFile: uberOAuthCredentialsLocation)
		{
			if let accessTok = dictionary.objectForKey("access_token") as? NSData
			{
				let encodedAccessToken = NSString(data: accessTok, encoding: NSUTF8StringEncoding)! as String
				accessToken = NSString(data: NSData(base64EncodedString: encodedAccessToken, options: nil)!, encoding: NSUTF8StringEncoding) as! String
			}
			if let refreshTok = dictionary.objectForKey("refresh_token") as? NSData
			{
				let encodedRefreshToken = NSString(data: refreshTok, encoding: NSUTF8StringEncoding)! as String
				refreshToken = NSString(data: NSData(base64EncodedString: encodedRefreshToken, options: nil)!, encoding: NSUTF8StringEncoding) as! String
			}
			expiration = dictionary.objectForKey("timeout") as? NSDate ?? NSDate(timeIntervalSinceNow: 0)
		}
		super.init()
	}
	
	/**
	This function adds the bearer access_token to the authorization field if it is available.
	
	:param: request A mutable URL Request which is modified to add the access token to the URL Request if one exists for the user.
	
	:returns: true if the access token was successfully added to the request. false otherwise.
	*/
	internal func addBearerAccessHeader(request: NSMutableURLRequest) -> Bool
	{
		if let accessToken = requestAccessToken()
		{
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			return true
		}
		return false
	}
	private func requestAccessToken(allowsRefresh: Bool = true) -> String?
	{
		if (accessToken == nil || refreshToken == nil || expiration == nil)
		{
			return nil
		}
		if (expiration.compare(NSDate(timeIntervalSinceNow: 0))
		 	== 	NSComparisonResult.OrderedDescending)
		{
			return accessToken
		}
		else if allowsRefresh
		{
			refreshAccessToken()
			return requestAccessToken(allowsRefresh: false)
		}
		return nil
	}
	private func refreshAccessToken()
	{
		let data = "client_id=\(sharedDelegate.clientID)&client_secret=\(sharedDelegate.clientSecret)&redirect_uri=\(sharedDelegate.redirectURI)&grant_type=refresh_token&refresh_token=\(refreshToken)"
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "POST"
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		let immutableRequest = request.copy() as! NSURLRequest
		var response : NSURLResponse?
		var error : NSError?
		
		let authData = NSURLConnection.sendSynchronousRequest(immutableRequest, returningResponse: &response, error: &error)
		
		if (error == nil)
		{
			parseAuthDataReceived(authData!)
		}
		else
		{
			let dict = NSJSONSerialization.JSONObjectWithData(authData!, options: nil, error: nil) as? NSDictionary
			uberLog(dict)
			uberLog(response)
			uberLog("Error in sending request for refresh token: \(error)")
		}
	}
	internal func getAuthTokenForCode(code: String)
	{
		let data = "code=\(code)&client_id=\(sharedDelegate.clientID)&client_secret=\(sharedDelegate.clientSecret)&redirect_uri=\(sharedDelegate.redirectURI)&grant_type=authorization_code"
		
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = HTTPMethod.Post.rawValue
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		let immutableRequest = request.copy() as! NSURLRequest
		var response : NSURLResponse?
		var error : NSError?
		
		let authData = NSURLConnection.sendSynchronousRequest(immutableRequest, returningResponse: &response, error: &error)
		
		if (error == nil)
		{
			parseAuthDataReceived(authData!)
		}
		else
		{
			println("Error in sending request for access token: \(error)")
			errorHandler?(response, error)
		}
	}
	private func parseAuthDataReceived(authData: NSData)
	{
		var jsonError : NSError?
		let authDictionary = NSJSONSerialization.JSONObjectWithData(authData, options: nil, error: &jsonError) as! NSDictionary
		if (jsonError == nil)
		{
			if let access = authDictionary.objectForKey("access_token") as? String
			{
				accessToken = access
				if let refresh = authDictionary.objectForKey("refresh_token") as? String, let timeout = authDictionary.objectForKey("expires_in") as? NSTimeInterval
				{
					let time = NSDate(timeInterval: timeout, sinceDate: NSDate(timeIntervalSinceNow: 0))
					refreshToken = refresh
					let encodedAccessToken = accessToken.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions(nil)
					let encodedRefreshToken = accessToken.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions(nil)
					let dictionary : NSDictionary = ["access_token" : encodedAccessToken, "refresh_token" : encodedRefreshToken, "timeout" : time];
					
					if dictionary.writeToFile(uberOAuthCredentialsLocation, atomically: true)
					{
						uberLog("Successfully cached and encrypted OAuth details")
					}
					else
					{
						uberLog("Failed to cached and encrypt OAuth details")
					}
				}
				successBlock?()
			}
		}
		else
		{
			uberLog("Error retrieving access token. Recieved JSON Error: \(jsonError)")
			errorHandler?(nil, jsonError)
		}
	}
	internal func setupOAuth2AccountStore()
	{
		if let accessCode = requestAccessToken()
		{
			successBlock?()
			return
		}
		var scopes = sharedDelegate.scopes.reduce("", combine: { $0.0 + "%20" + $0.1.description })
		scopes = scopes.substringFromIndex(advance(scopes.startIndex, 3))
		let redirectURL = sharedDelegate.redirectURI.stringByAddingPercentEncodingWithAllowedCharacters(.URLPasswordAllowedCharacterSet())!
		let URL = NSURL(string: "https://login.uber.com/oauth/authorize?response_type=code&client_id=\(sharedDelegate.clientID)&redirect_uri=\(redirectURL)&scope=\(scopes)")!
		let request = NSURLRequest(URL: URL)
		generateCodeForRequest(request)
	}
	internal func setCallbackBlocks(#successBlock: UberSuccessBlock?, errorBlock: UberErrorHandler?)
	{
		self.successBlock = successBlock
		errorHandler = errorBlock
	}
}