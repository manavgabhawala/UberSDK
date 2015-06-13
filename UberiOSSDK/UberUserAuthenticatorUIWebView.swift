//
//  UberUserAuthenticator.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Foundation
import UIKit

extension UberManager
{
	/**
	Call this function before using any end points that require user OAuth 2.0. This function will handle displaying the webview and saving and caching the access and refresh tokens to the disk in an encrypted format.
	
	- parameter view: 			 The view on which to display the webview where authentication will occur.
	- parameter completionBlock: The block of code to execute once we have successfully recieved the user's access token.
	- parameter errorHandler:    An error occurred while getting the user's login. Somehow handle the error in this block.
	*/
	@objc public func performUserAuthorizationToView(view: UIView, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		userAuthenticator.setCallbackBlocks(successBlock: success, errorBlock: failure)
		userAuthenticator.setupOAuth2AccountStore(view)
	}
}

extension UberUserAuthenticator
{
	internal func generateCodeForRequest<T: Viewable>(request: NSURLRequest, onView superview: T)
	{
		let view = UIWebView()
		view.scalesPageToFit = true
		view.delegate = self
		view.loadRequest(request)
		view.frame.size = superview.frame.size
		dispatch_async(dispatch_get_main_queue(), {
			superview.addSubview(view as! T)
		})
		
	}
}
extension UberUserAuthenticator : UIWebViewDelegate
{
	@objc func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
	{
		if let URL = request.URL?.absoluteString
		{
			if URL.hasPrefix(redirectURI)
			{
				var code : String?
				if let URLParams = request.URL?.query?.componentsSeparatedByString("&")
				{
					for param in URLParams
					{
						let keyValue = param.componentsSeparatedByString("=")
						let key = keyValue.first
						if key == "code"
						{
							code = keyValue.last
						}
					}
				}
				if let code = code
				{
					getAuthTokenForCode(code)
					webView.removeFromSuperview()
				}
				else
				{
					self.errorHandler?(UberError(code: "access_code_not_found", message: "The callback URL did not contain the authentication token required. The code we recieved was nil.", fields: nil, response: nil))
				}
				return false
			}
		}
		return true
	}
	@objc func webView(webView: UIWebView, didFailLoadWithError error: NSError?)
	{
		print(error?.localizedDescription)
		//		errorHandler?(UberError(error: error))
	}
	@objc func webViewDidFinishLoad(webView: UIWebView)
	{
	}
}

extension UIView : Viewable
{ }
