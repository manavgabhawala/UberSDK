//
//  ViewController.swift
//  UberUserAutenticationTestApp
//
//  Created by Manav Gabhawala on 6/13/15.
//
//

import UIKit
@testable import UberiOSSDK

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	override func viewDidAppear(animated: Bool)
	{
		super.viewDidAppear(animated)
		performUserAuthentication()
	}
	func performUserAuthentication()
	{
		manager.logUberUserOut(completionBlock: nil, errorHandler: nil)
		manager.performUserAuthorizationToView(view, completionBlock: {
			print("Success. User is now authenticated")
			assert(manager.userAuthenticator.authenticated(), "We need to make sure that we are successfully adding the bearer accesses to headers of URL requests.")
			}, errorHandler: { error in
				assertionFailure("Failed to authenticate the user. The error: \(error)")
		})
	}
}

