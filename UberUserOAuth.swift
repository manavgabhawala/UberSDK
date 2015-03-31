//
//  UberUserOAuth.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/30/15.
//
//

import Foundation


internal class UberUserOAuth
{
	var delegate: UberManagerDelegate
	init(delegate: UberManagerDelegate)
	{
		self.delegate = delegate
	}
	/**
	This function adds the
	
	:param: request A mutable URL Request which is modified to add the access token to the URL Request if one exists for the user.
	
	:returns: true if the access token was successfully added to the request. false otherwise.
	*/
	func addBearerAccessHeader(request: NSMutableURLRequest) -> Bool
	{
		if let accessToken = requestAccessToken()
		{
			request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
			return true
		}
		return false
	}
	func requestAccessToken() -> String?
	{
		return nil
	}
	func refreshAccessToken()
	{
		
	}
	
	func setupOAuth2AccountStore()
	{
		let URL = NSURL(string: "https://login.uber.com/oauth/authorize?response_type=code&client_id=\(delegate.clientID)&client_secret=\(delegate.clientSecret)&grant_type=authorization_code&redirect_uri=\(delegate.redirectURI)")!
		let request = NSMutableURLRequest(URL: URL)
		request.HTTPMethod = "GET"
	}
}