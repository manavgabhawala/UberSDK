//
//  UberRequestWebView.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import Cocoa
import WebKit
import CoreLocation

extension UberManager
{
	///  Create a new request for the logged in user.
	///
	///  - parameter startLatitude:  The beginning or "pickup" latitude.
	///  - parameter startLongitude: The beginning or "pickup" longitude.
	///  - parameter endLatitude:    The final or destination latitude.
	///  - parameter endLongitude:   The final or destination longitude.
	///  - parameter productID:      The unique ID of the product being requested.
	///  - parameter view:           The view on which to show any surges if applicable.
	///  - parameter surge:          An optional string that allows you to specify the surge ID returned by Uber if surges are applicable. Don't worry about this parameter just ensure the view passed in is visible and surges will be taken care of automatically.
	///  - parameter success:        The block of code to be executed on a successful creation of the request.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func createRequest(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, productID: String, surgeView view: NSView, surgeID surge : String? = nil, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		createRequest(startLatitude: startLatitude, startLongitude: startLongitude, endLatitude: endLatitude, endLongitude: endLongitude, productID: productID, surgeConfirmation: nil, completionBlock: success, errorHandler: { error in
			guard let JSON = error.JSON
			else { failure?(error); return }
			if error.errorCode == "surge"
			{
				guard let meta = JSON["meta"], let surgeDict = meta["surge_confirmation"] as? [NSObject : AnyObject], let href = surgeDict["href"] as? String
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
	
	///  Create a new request for the logged in user.
	///
	///  - parameter startLocation: The beginning or "pickup" location.
	///  - parameter endLocation:   The final or destination location.
	///  - parameter productID:      The unique ID of the product being requested.
	///  - parameter view:           The view on which to show any surges if applicable.
	///  - parameter success:        The block of code to be executed on a successful creation of the request.
	///  - parameter failure:   This block is called if an error occurs. This block takes an `UberError` argument and returns nothing. In most cases a properly formed `UberError` object will be returned but in some very rare cases an Unknown Uber Error can be returned when there it is not possible for us to recover any error information.
	/// - Warning: User authentication must be completed before calling this function.
	@objc public func createRequest(startLocation: CLLocation, endLocation: CLLocation, productID: String, surgeView view: NSView, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)
	{
		createRequest(startLatitude: startLocation.coordinate.latitude, startLongitude: startLocation.coordinate.latitude, endLatitude: endLocation.coordinate.latitude, endLongitude: endLocation.coordinate.longitude, productID: productID, surgeView: view, surgeID : self.surgeCode, completionBlock: success, errorHandler: failure)
	}

}

extension UberManager : WebPolicyDelegate
{
	public func webView(webView: WebView!, decidePolicyForNavigationAction actionInformation: [NSObject : AnyObject]!, request: NSURLRequest!, frame: WebFrame!, decisionListener listener: WebPolicyDecisionListener!)
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