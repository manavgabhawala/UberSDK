//
//  UberUserAuthenticatorWebView.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import Cocoa
import WebKit

extension UberManager
{
	///  Call this function before using any end points that require user OAuth 2.0. This function will handle displaying the webview and saving and caching the access and refresh tokens to the disk in an encrypted format.
	///
	///  - parameter view:    The view on which to display the webview where authentication will occur.
	///  - parameter success: The block of code to execute once we have successfully recieved the user's access token.
	///  - parameter failure: An error occurred while getting the user's login. Somehow handle the error in this block.
	@objc public func performUserAuthorizationToView(view: NSView, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
	{
		userAuthenticator.setCallbackBlocks(successBlock: success, errorBlock: failure)
		userAuthenticator.setupOAuth2AccountStore(view)
	}
}

extension UberUserAuthenticator
{
	func generateCodeForRequest<T: Viewable>(request: NSURLRequest, onView superview: T)
	{
		let view = WebView()
		view.frame = superview.frame
		view.policyDelegate = self
		view.frameLoadDelegate = self
		view.frame.size = superview.frame.size
		view.mainFrame.loadRequest(request)
		dispatch_async(dispatch_get_main_queue(), {
			superview.addSubview(view as! T)
		})
	}
}
extension UberUserAuthenticator : WebPolicyDelegate, WebFrameLoadDelegate
{
	func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
	{
		guard let URL = request?.URL?.absoluteString where URL.hasPrefix(redirectURI)
			else
		{
			listener.use()
			return
		}
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
		guard let theCode = code
			else
		{
			self.errorHandler?(UberError(code: "access_code_not_found", message: "The callback URL did not contain the authentication token required. The code we recieved was nil.", fields: nil, response: nil, errorResponse: nil, JSON: [NSObject: AnyObject]()))
			listener.use()
			return
		}
		getAuthTokenForCode(theCode)
		webView.removeFromSuperview()
		listener.ignore()
	}
}


extension NSView: Viewable
{ }