//
//  UberProductNSImage.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 3/31/15.
//
//

import Foundation
import AppKit

private func downloadImage<T: UberObjectHasImage>(object: T, successCallbackBlock success: (T, image: NSImage, fileLocation: String) -> Void, andFailureCallbackBlock failure: UberErrorHandler?)
{
	if let URL = object.imageURL
	{
		let request = NSURLRequest(URL: URL)
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.downloadTaskWithRequest(request, completionHandler: {(URL, response, error) in
			if (error == nil)
			{
				let fileManager = NSFileManager.defaultManager()
				if let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first as? NSURL
				{
					let fileURL = documentsURL.URLByAppendingPathComponent(URL.lastPathComponent!)
					var moveError : NSError?
					if fileManager.moveItemAtURL(URL, toURL: fileURL, error: &moveError)
					{
						if let image = NSImage(contentsOfFile: fileURL.path!)
						{
							success(object, image: image, fileLocation: fileURL.path!)
						}
						else
						{
							failure?(response, error)
						}
					}
					else
					{
						failure?(response, moveError)
					}
				}
				else
				{
					failure?(response, error)
				}
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


public typealias UberProductImageDownloadedBlock = (product: UberProduct, image: NSImage, fileLocation: String) -> Void

extension UberProduct
{
	/**
	Call this function on a product to `asynchronously` download a product's image.
	
	:param: completionBlock The block of code to execute on success. This block takes 3 parameters the product for which the image was downloaded, an NSImage representation of the image, and the location to the cached image.
	:param: errorHandler The block of code to execute on failure.#failure description#>
	*/
	public func downloadImageInBackground(completionBlock success: UberProductImageDownloadedBlock?, errorHandler failure: UberErrorHandler?)
	{
		downloadImage(self, successCallbackBlock: success, andFailureCallbackBlock: failure)
	}
}

public typealias UberUserImageDownloadedBlock = (user: UberUser, image: NSImage, fileLocation: String) -> Void

extension UberUser
{
	/**
	Call this function on an `UberUser` to `asynchronously` download the user's image.
	
	:param: completionBlock The block of code to execute on success. This block takes 3 parameters the user for whom the image was downloaded, a NSImage representation of the image, and the location to the cached image.
	:param: errorHandler The block of code to execute on an error.
	*/
	public func downloadImageInBackground(completionBlock success: UberUserImageDownloadedBlock, errorHandler failure: UberErrorHandler?)
	{
		downloadImage(self, successCallbackBlock: success, andFailureCallbackBlock: failure)
	}
}

public typealias UberDriverImageDownloadedBlock = (UberDriver, image: NSImage, fileLocation: String) -> Void

extension UberDriver
{
	/**
	Call this function on an `UberDriver` to `asynchronously` download the driver's image.
	
	:param: completionBlock The block of code to execute on success. This block takes 3 parameters the user for whom the image was downloaded, a NSImage representation of the image, and the location to the cached image.
	:param: errorHandler The block of code to execute on an error.
	*/
	public func downloadImageInBackground(completionBlock success: UberDriverImageDownloadedBlock, errorHandler failure: UberErrorHandler?)
	{
		downloadImage(self, successCallbackBlock: success, andFailureCallbackBlock: failure)
	}
}

public typealias UberVehicleImageDownloadedBlock = (UberVehicle, image: NSImage, fileLocation: String) -> Void

extension UberVehicle
{
	/**
	Call this function on an `UberVehicle` to `asynchronously` download the vehicle's image.
	
	:param: completionBlock The block of code to execute on success. This block takes 3 parameters the user for whom the image was downloaded, a NSImage representation of the image, and the location to the cached image.
	:param: errorHandler The block of code to execute on an error.
	*/
	public func downloadImageInBackground(completionBlock success: UberVehicleImageDownloadedBlock, errorHandler failure: UberErrorHandler?)
	{
		downloadImage(self, successCallbackBlock: success, andFailureCallbackBlock: failure)
	}
}