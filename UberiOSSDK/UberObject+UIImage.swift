//
//  UberObject+UIImage.swift
//  UberSDK
//
//  Created by Manav Gabhawala on 6/12/15.
//
//

import UIKit

extension UberObjectHasImage
{
	func downloadImage(completionBlock success: (UIImage, Self) -> Void, errorHandler failure : UberErrorHandler?)
	{
		let fileManager = NSFileManager.defaultManager()
		guard let URL = imageURL else { failure?(UberError(code: "missing_image", message: "No image URL was found so downloading the image was not possible.", fields: nil, response: nil)); return }
		let documentsURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
		if !fileManager.fileExistsAtPath(documentsURL.path!)
		{
			do {
				try fileManager.createDirectoryAtURL(documentsURL, withIntermediateDirectories: true, attributes: nil)
			}
			catch let error as NSError
			{
				failure?(UberError(error: error))
			}
		}
		if let data = NSData(contentsOfURL: documentsURL.URLByAppendingPathComponent(URL.lastPathComponent!)), let image = UIImage(data: data)
		{
			success(image, self)
			return
		}
		let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
		let task = session.downloadTaskWithRequest(NSURLRequest(URL: URL)) { downloadedURL, response, error in
			guard error == nil else { failure?(UberError(error: error!, response: response)); return }
			let fileURL = documentsURL.URLByAppendingPathComponent(URL.lastPathComponent!)
			do
			{
				try fileManager.moveItemAtURL(downloadedURL!, toURL: fileURL)
				guard let image = UIImage(contentsOfFile: fileURL.path!)
					else { failure?(UberError(error: error!, response: response)); return }
				success(image, self)
			}
			catch let error as NSError
			{
				failure?(UberError(error: error, response: response))
			}
			catch
			{
				failure?(nil)
			}
		}
		task?.resume()
	}
}
