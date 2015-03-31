//
//  UberProductUIImage.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import UIKit

public typealias UberProductImageDownloadedBlock = (UberProduct, UIImage) -> Void

extension UberProduct
{
	public func downloadImageInBackground(successCallbackBlock success: UberProductImageDownloadedBlock?, andFailureCallbackBlock failure: UberErrorHandler?)
	{
		let request = NSURLRequest(URL: imageURL)
		NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler: {(response, data, error) in
			if error == nil
			{
				if let image = UIImage(data: data)
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
}