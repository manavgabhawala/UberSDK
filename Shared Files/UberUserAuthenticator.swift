//
//  UberUserAuthenticator.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation

internal class UberUserAuthenticator : NSObject
{
	private let refreshSemaphore = dispatch_semaphore_create(1)
	
	private var accessToken : String?
	private var refreshToken: String?
	private var expiration : NSDate?
	private var uberOAuthCredentialsLocation : String
	
	private var clientID: String
	private var clientSecret : String
	internal var redirectURI : String
	private var scopes : [UberScopes]
	
	private var completionBlock : UberSuccessBlock?
	internal var errorHandler : UberErrorHandler?
	internal var viewController : AnyObject!
	
	internal init(clientID: String, clientSecret: String, redirectURI: String, scopes: [UberScopes])
	{
		self.clientID = clientID
		self.clientSecret = clientSecret
		self.redirectURI = redirectURI
		self.scopes = scopes
		if let directory = NSSearchPathForDirectoriesInDomains(.ApplicationSupportDirectory, NSSearchPathDomainMask.UserDomainMask, true).first
		{
			uberOAuthCredentialsLocation = "\(directory)/Authentication.plist"
			let fileManager = NSFileManager()
			if !fileManager.fileExistsAtPath(directory)
			{
				try! fileManager.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
			}
			if !fileManager.fileExistsAtPath(uberOAuthCredentialsLocation)
			{
				fileManager.createFileAtPath(uberOAuthCredentialsLocation, contents: nil, attributes: nil)
			}
		}
		else
		{
			uberOAuthCredentialsLocation = ""
		}
		if let dictionary = NSDictionary(contentsOfFile: uberOAuthCredentialsLocation)
		{
			if let accessTok = dictionary.objectForKey("access_token") as? NSData, let encodedAccessToken = String(data: accessTok)
			{
				accessToken = String(data: NSData(base64EncodedString: encodedAccessToken, options: []))
			}
			if let refreshTok = dictionary.objectForKey("refresh_token") as? NSData, let encodedRefreshToken = String(data: refreshTok)
			{
				refreshToken = String(data: NSData(base64EncodedString: encodedRefreshToken, options: []))
			}
			expiration = dictionary.objectForKey("timeout") as? NSDate
		}
	}
	
	/**
	This function adds the bearer access_token to the authorization field if it is available.
	
	- parameter request: A mutable URL Request which is modified to add the access token to the URL Request if one exists for the user.
	
	- returns: true if the access token was successfully added to the request. false otherwise.
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
		if expiration! > NSDate.now
		{
			return accessToken
		}
		else if allowsRefresh
		{
			refreshAccessToken()
			dispatch_semaphore_wait(refreshSemaphore, DISPATCH_TIME_FOREVER)
			return requestAccessToken(false)
		}
		return nil
	}
	private func refreshAccessToken()
	{
		dispatch_semaphore_wait(refreshSemaphore, DISPATCH_TIME_NOW)
		let data = "client_id=\(clientID)&client_secret=\(clientSecret)&redirect_uri=\(redirectURI)&grant_type=refresh_token&refresh_token=\(refreshToken)"
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "POST"
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		performFetchForAuthData(request.copy() as! NSURLRequest)
	}
	internal func getAuthTokenForCode(code: String)
	{
		let data = "code=\(code)&client_id=\(clientID)&client_secret=\(clientSecret)&redirect_uri=\(redirectURI)&grant_type=authorization_code"
		
		let URL = NSURL(string: "https://login.uber.com/oauth/token")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = HTTPMethod.Post.rawValue
		request.HTTPBody = data.dataUsingEncoding(NSUTF8StringEncoding)
		
		performFetchForAuthData(request.copy() as! NSURLRequest)
	}
	private func performFetchForAuthData(request: NSURLRequest)
	{
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.dataTaskWithRequest(request, completionHandler: {(data, response, error) in
			if (error == nil)
			{
				self.parseAuthDataReceived(data!)
				// If we can't acquire it, it returns imeediately and it means that someone is waiting and needs to be signalled.
				// If we do acquire it we release it immediately because we don't actually want to hold it for anytime in the future.
				dispatch_semaphore_wait(self.refreshSemaphore, DISPATCH_TIME_NOW)
				dispatch_semaphore_signal(self.refreshSemaphore)
			}
			else
			{
				self.errorHandler?(UberError(JSONData: data, response: response) ??  UberError(error: error, response: response))
			}
		})
		task?.resume()
	}
	private func parseAuthDataReceived(authData: NSData)
	{
		do
		{
			guard let authDictionary = try NSJSONSerialization.JSONObjectWithData(authData, options: []) as? [NSObject : AnyObject]
				else { return }
			
			guard let access = authDictionary["access_token"] as? String,
				let refresh = authDictionary["refresh_token"] as? String,
				let timeout = authDictionary["expires_in"] as? NSTimeInterval
				else { throw NSError(domain: "UberAuthenticationError", code: 1, userInfo: nil) }
			accessToken = access
			refreshToken = refresh
			let time = NSDate(timeInterval: timeout, sinceDate: NSDate(timeIntervalSinceNow: 0))
			let encodedAccessToken = accessToken!.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions([])
			let encodedRefreshToken = refreshToken!.dataUsingEncoding(NSUTF8StringEncoding)!.base64EncodedDataWithOptions([])
			let dictionary : NSDictionary = ["access_token" : encodedAccessToken, "refresh_token" : encodedRefreshToken, "timeout" : time];
			dictionary.writeToFile(uberOAuthCredentialsLocation, atomically: true)
			completionBlock?()
		}
		catch let error as NSError
		{
			errorHandler?(UberError(error: error))
		}
		catch
		{
			errorHandler?(UberError(JSONData: authData))
		}
	}
	
	internal func setupOAuth2AccountStore<T: Viewable>(view: T)
	{
		if let _ = requestAccessToken()
		{
			completionBlock?()
			return
		}
		var scopesString = scopes.reduce("", combine: { $0.0 + "%20" + $0.1.description })
		scopesString = scopesString.substringFromIndex(advance(scopesString.startIndex, 3))
		let redirectURL = redirectURI.stringByAddingPercentEncodingWithAllowedCharacters(.URLPasswordAllowedCharacterSet())!
		let URL = NSURL(string: "https://login.uber.com/oauth/authorize?response_type=code&client_id=\(clientID)&redirect_uri=\(redirectURL)&scope=\(scopesString)")!
		let request = NSURLRequest(URL: URL)
		generateCodeForRequest(request, onView: view)
	}
	internal func setCallbackBlocks(successBlock successBlock: UberSuccessBlock?, errorBlock: UberErrorHandler?)
	{
		completionBlock = successBlock
		errorHandler = errorBlock
	}
	internal func logout(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		accessToken = nil
		refreshToken = nil
		expiration = nil
		let fileManager = NSFileManager.defaultManager()
		if fileManager.fileExistsAtPath(uberOAuthCredentialsLocation)
		{
			do
			{
				try fileManager.removeItemAtPath(uberOAuthCredentialsLocation)
				success?()
			}
			catch let error as NSError
			{
				failure?(UberError(error: error))
			}
			catch
			{
				failure?(nil)
			}
		}
		else
		{
			success?()
		}
	}
}