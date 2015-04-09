//
//  UberUserOAuthiOS.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import UIKit

extension UberUserOAuth
{
	func generateCodeForRequest(request: NSURLRequest)
	{
		let view = UIWebView()
		view.frame = UIScreen.mainScreen().bounds
		view.scalesPageToFit = true
		view.delegate = self
		view.loadRequest(request)
	}
}
extension UberUserOAuth : UIWebViewDelegate
{
	func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool
	{
		if let URL = request.URL?.absoluteString
		{
			if URL.hasPrefix(sharedDelegate.redirectURI)
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
							println("Code: \(code)\n")
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
					uberLog("Error from UIWebView")
				}
				return false
			}
		}
		return true
	}
	func webView(webView: UIWebView, didFailLoadWithError error: NSError)
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
		//TODO: Show error
		uberLog(error)
	}
	func webViewDidFinishLoad(webView: UIWebView)
	{
		UIApplication.sharedApplication().networkActivityIndicatorVisible = false
	}

}