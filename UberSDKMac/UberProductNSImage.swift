//
//  UberProductNSImage.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import AppKit

public typealias UberProductImageDownloadedBlock = (UberProduct, NSImage!) -> Void

extension UberProduct
{
	public func downloadImageInBackground(successCallbackBlock success: UberProductImageDownloadedBlock?, andFailureCallbackBlock failure: UberErrorHandler?)
	{
		if let imageURL = imageURL
		{
			let request = NSURLRequest(URL: imageURL)
			NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
				if error == nil
				{
					if let image = NSImage(data: data)
					{
						success?(self, image)
					}
					failure?(response, error)
				}
				else
				{
					failure?(response, error)
				}
			})
		}
		else
		{
			failure?(nil, NSError(domain: "UberSDK", code: 1, userInfo: ["error" : "Image URL is not valid. Failed to download image."]))
		}
	}
}
