//
//  UberRequestWebView.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import AppKit
import WebKit
import CoreLocation

extension UberManager
{
	/**
	Create a new request for the logged in user.
	
	- parameter startLatitude:   The beginning or "pickup" latitude.
	- parameter startLongitude:  The beginning or "pickup" longitude.
	- parameter endLatitude:     The final or destination latitude.
	- parameter endLongitude:    The final or destination longitude.
	- parameter productID:       The unique ID of the product being requested.
	- parameter surgeView:		 The view on which to show any surges if applicable.
	- parameter completionBlock: The block of code to be executed on a successful creation of the request.
	- parameter errorHandler:    The block of code to be executed if an error occurs.
	*/
	@objc public func createRequest(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, productID: String, surgeView view: NSView, surgeID surge : String? = nil, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		createRequest(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, productID: productID, surgeConfirmation: nil, completionBlock: success, errorHandler: { err in
			guard let error = err, let JSON = error.JSON else { failure?(err); return }
			if error.errorCode == "surge_confirmation"
			{
				guard let surgeDict = JSON["meta"] as? [NSObject : AnyObject], let href = surgeDict["href"] as? String
				else
				{
					failure?(error)
					return
				}
				let webView = WebView(frame: view.frame)
				webView.policyDelegate = self
				self.surgeLock.lock()
				webView.mainFrame.loadRequest(NSURLRequest(URL: NSURL(string: href)!))
				view.addSubview(webView)
				self.surgeLock.lock()
				self.createRequest(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, productID: productID, surgeView: view, surgeID : self.surgeCode, completionBlock: success, errorHandler: failure)
			}
			else if error.errorCode == "retry_request"
			{
				self.createRequest(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, productID: productID, surgeView: view, surgeID : self.surgeCode, completionBlock: success, errorHandler: failure)
			}
			else
			{
				failure?(error)
			}
		})
	}
	
	/**
	Create a new request for the logged in user.
	
	- parameter startLocation:      The beginning or "pickup" location.
	- parameter endLocation:        The final or destination location.
	- parameter productID:          The unique ID of the product being requested.
	- parameter surgeView:		 The view on which to show any surges if applicable.
	- parameter completionBlock:    The block of code to be executed on a successful creation of the request.
	- parameter errorHandler:       The block of code to be executed if an error occurs.
	*/
	@objc public func createRequest(startLocation: CLLocation, endLocation: CLLocation, productID: String, surgeView view: NSView, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		createRequest(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.latitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, productID: productID, surgeView: view, surgeID : self.surgeCode, completionBlock: success, errorHandler: failure)
	}

}

extension UberManager : WKNavigationDelegate
{
	override public func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
	{
		defer { listener.use() }
		
		guard actionInformation[WebActionNavigationTypeKey]?.intValue != nil else { return }
		guard let URL = request.URL?.absoluteString where URL.hasPrefix(delegate.surgeConfirmationRedirectURI) else { return }
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
			webView.removeFromSuperview()
			surgeCode = code
		}
		surgeLock.unlock()
	}
}