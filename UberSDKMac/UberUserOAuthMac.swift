//
//  UberUserOAuthMac.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import WebKit

extension UberUserOAuth
{
	func generateCodeForRequest(request: NSURLRequest)
	{
		let view = WKWebView()
		view.frame = NSApplication.sharedApplication().keyWindow!.contentView.frame
		view.policyDelegate = self
		view.frameLoadDelegate = self
		let window = NSWindow()
		(NSApplication.sharedApplication().keyWindow!.contentView as! NSView).addSubview(view)
	}
	
}
extension UberUserOAuth : WKNavigationDelegate
{
	override func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
	{
		if let actionKey = actionInformation[WebActionNavigationTypeKey]?.intValue
		{
			listener.use()
		}
		else
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
						uberLog("Error from WebView")
					}
					listener.use()
				}
			}
		}
	}
}