# UberSDK for iOS and Mac OS X - Swift And Objective C

[![Latest Release](https://img.shields.io/badge/release-0.0.1-blue.svg)](https://github.com/manavgabhawala/UberSDK)
[![Build Status](https://img.shields.io/badge/build-passing-brightgreen.svg)](https://github.com/manavgabhawala/UberSDK)
[![License](https://img.shields.io/badge/license-Apache%20License-blue.svg)](https://github.com/manavgabhawala/UberSDK)
[![Platform](https://img.shields.io/badge/platform-iOS%20%7C%20OS%20X-000000.svg)](https://github.com/manavgabhawala/UberSDK)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

This is an SDK for the new Uber API released in March 2015. This SDK allows developers to easily use the Uber API without having to worry about implementing any OAuth 2.0 or perform any Network Requests. This SDK supports all end points available at https://developer.uber.com/v1/endpoints/ as of 22nd June 2015. For the Uber API change log of when it was last updated, click [here](https://developer.uber.com/v1/api-reference/)

## Installation Instructions 

### Direct Installation
This method is recommended for people who don't want to use Cocoa pods, or Carthrage or any other dependency manager. This method is very easy to setup and use. This works with both Swift and Objective-C projects as well those which mix and match code.
- **[Download](https://github.com/manavgabhawala/UberSDK/releases/download/v0.0.1/Frameworks.zip)** the Mac and iOS Frameworks.
- Unzip the archive you downloaded and you should see 2 framework bundles: `UberMacSDK.framework` and `UberiOSSDK.framework`.
- Drag the `UberMacSDK.framework` for a Mac target and the `UberiOSSDK.framework` for an iOS target and if you are using both, drag both into the your Xcode project. Pretty simple stuff. See the screenshot
![Dragging](https://github.com/manavgabhawala/UberSDK/blob/master/Examples/Dragging.png)
- Then you will be presented with a dialog like the screenshot. Make sure that you check the Copy Files If Needed button. Also, set the target as required. If you are dragging in the iOS framework select the iOS app as the target and likewise for Mac. If you are importing both you can set the targets after importing, see the next step.
![Importing](https://github.com/manavgabhawala/UberSDK/blob/master/Examples/Importing.png)
- Now if you need to change the target of the framework you can do this by selecting the framework in the left side bar and then selecting the relevant targets in the inspector window. See the screenshot.
![Targetting](https://github.com/manavgabhawala/UberSDK/blob/master/Examples/Targetting.png)
- Finally, if somehow things went south before reporting an isuse make sure that the target is linked to the library. If it is not click the plus as shown in the screenshot and add the framework.
![Linking](https://github.com/manavgabhawala/UberSDK/blob/master/Examples/Linking.png)

- And now to use it:

#### Swift

```swift
import UberiOSSDK // or UberMacSDK for Mac targets
// That import statement is all you need. Now you can start using the SDK as described below
```

#### Objective C
```objc
@import UberiOSSDK; // or UberMacSDK for Mac targets
// That import statement is all you need. Now you can start using the SDK as described below
```

### Cocoa Pods
Coming soon.

### Carthage
This project is compatible with Carthage. To install it using Carthage add this to your `Cartfile`
```
github "manavgabhawala/UberSDK" == 0.0.1
```
For more information about Carthage and how to set it up click [here](https://github.com/Carthage/Carthage).

## Features

- [x] Full Objective-C and Swift support.
- [x] Small framework file with descriptive function headers.
- [x] Supports all Uber API endpoints.
- [x] Doesn't block the main thread by using callbacks. Fully asynchronous.
- [x] Incredible error handling support including full details of the error.
- [x] Full localization support including all 17 languages supported by Uber
- [x] Fully native SDK for iOS and Mac including features like using CoreLocation where useful, uses NSDates where relevant and even supports descriptions (`CustomStringConvertible`) so debugging is pain free.
- [x] Makes use of Swift 2.0's generics, protocol extension, guards and defer statements to give you a great API to use.
- [x] Zero configuration to setup and use.

## Documentation and Usage 
### Initialization
The basic way to initialize the SDK is creating an instance of the `UberManager` object. You should create only one instance of the `UberManager` at a time. This instance is thread safe in that you can use the same instance on multiple threads but if you initialize a new UberManager your old UberManager will start accessing the newer app properties that you set. The intention of this SDK was to allow you to use public functions available after initializing an UberManager.

To initialize the `UberManager` You can either implement the `UberManagerDelegate` or pass in all the values required for the application setup to the init function. This includes the **client key**, **client secret**, **server token** and **redirectURI**, all of which can be found on your [Uber App Dashboard](https://developer.uber.com/apps/). Further, you must also return a base URL from the enum `UberBaseURL` which has two types `ProductionAPI` and `SandboxAPI`. This allows you to set which API endpoint you would like to communicate with. You must also return an `Array` of `UberScopes`, which are needed for User Authentication. If you are not planning on using endpoints that require User Authentication return an empty array. This `Array` must be the `rawValue`'s of the enumeration type (this is so that Objective-C NSArrays can be supported too). Here is how you can initialize a manager using a delegate and passing values into the initializer in both Swift and Objective C.

####Implementation With Delegate
#####Swift
```swift
class SomeClass : NSObject
{
func someFunction()
{
let manager = UberManager(delegate: self)
}
}

extension SomeClass : UberManagerDelegate 
{
var applicationName: String { get { return "APP_NAME" } }
var clientID : String { get { return "CLIENT_ID" } }
var clientSecret: String { get { return "CLIENT_SECRET" } }
var serverToken : String { get { return "SERVER_TOKEN" } }
var redirectURI : String { get { return "REDIRECT_URI" } }
var baseURL : UberBaseURL { get { return .SandboxAPI } }
var scopes : [Int] { get { return [UberScopes.Profile.rawValue, UberScopes.Request.rawValue] } }
var surgeConfirmationRedirectURI : String { get { return "SURGE_REDIRECT_URI" } }
}
```
#####Objective C
```objc
@interface SomeClass : NSObject <UberManagerDelegate>

@property (nonatomic, readonly, copy) NSString * __nonnull applicationName;

@property (nonatomic, readonly, copy) NSString * __nonnull clientID;

@property (nonatomic, readonly, copy) NSString * __nonnull clientSecret;

@property (nonatomic, readonly, copy) NSString * __nonnull serverToken;

@property (nonatomic, readonly, copy) NSString * __nonnull redirectURI;

@property (nonatomic, readonly) enum UberBaseURL baseURL;

@property (nonatomic, readonly) NSArray<int> * __nonnull scopes;

@property (nonatomic, readonly, copy) NSString * __nonnull surgeConfirmationRedirectURI;

@end

@implementation SomeClass
-(void) someFunction
{
// You must assign the properties before creating a new instance.
UberManager *newManager = [[UberManager alloc] initWithDelegate:self];
}
@end

```
####Implementation With Initializer
#####Swift
```swift
class SomeClass : NSObject
{
func someFunction()
{
let manager = UberManager(applicationName: "APP_NAME", clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET", serverToken: "SERVER_TOKEN", redirectURI: "REDIRECT_URI", surgeConfirmationRedirectURI: "SURGE_REDIRECT", baseURL: .SandboxAPI, scopes: [.Profile, .Request])
}

}
```
#####Objective C
```objc
NSArray *scopes = @[UberScopesProfile, UberScopesRequest];
UberManager *manager = [[UberManager alloc] initWithApplicationName:@"APP_NAME"
clientID:@"CLIENT_ID"
clientSecret:@"CLIENT_SECRET"
serverToken:@"SERVER_TOKEN"
redirectURI:@"REDIRECT_URI"
surgeConfirmationRedirectURI:@"SURGE_REDIRECT_URI"
baseURL:UberBaseURLSandboxAPI
scopes:scopes];
```

### User Authentication with OAuth 2.0
Once you have initialized the `UberManager` instance, you must get a user to log in before you can use any of the endpoints that require User Authentication. These include:
- Fetching a User's Profile
- Fetching a User's Activity History
- Creating, Cancelling and Viewing a User's Requests
- Request Receipts and Request Maps.

Before calling any of these functions you must call `performUserAuthorizationToView(view:completionBlock:errorHandler:)` on your `UberManager` instance. In an iOS App we will present a `UIWebView` on the `view` you pass in which should be a UIView or a subclass of it. We then ask the user to login with the `UberScopes` you provided during initialization. On a Mac App we do the same thing except with a `WebView` on an `NSView`. All the nitty grittys of implementing the OAuth2.0 has been done for you including saving an encrypted `access_token`, `refresh_token` and `expiration` to the disk. Further, the `WebView` gets dismissed automatically, too. If the user logs in the completionBlock will get executed else the errorHandler block will get executed with an `UberError` as a parameter. Look at [`Error Handling`](#error-handling) section for more details on error handlers. Once the `completionBlock` is called you know that the user has successfully logged in and we have their access token. You can now call the other functions in the SDK to communicate with the API.
#####Swift 
```swift
manager.performUserAuthorizationToView(someUIViewInstance, completionBlock: { 
// Yay! The user is now logged in.
}, errorHandler: { uberError in 
print(uberError)
// TODO: Some awesome error handling.
})
```
#####Objective C
```objc
[manager performUserAuthorizationToView: someUIViewInstance withCompletionBlock:^() {
// Yay! The user is now logged in!
} errorHandler:^(UberError* uberError, NSURLResponse* response,
NSError* error){
// TODO: Some amazing error handling
}];
```
### Function Calls
Now, you can make all the function calls you like to access the API endpoints. All of these functions are available in the UberManager class and have detailed header docs and can be invoked in a similar manner. For every endpoint on the UberAPI there is a matching function in the manager class which takes parameters as required and ensures typesafety. 
One example has been provided for you, the headers of the rest of the functions are in swift after that.

#####Swift
```swift
manager.fetchProductsForLocation(someCLLocation, completionBlock: { products in  
products.map { print($0) }
}, errorHandler: { error in
print(error)
})
```
#####Objective C
```objc

```

#### All Function Headers

```swift
// MARK: User Authentication

public func performUserAuthorizationToView(view: UIView, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?) // The UIView is an NSView in the MacSDK.


public func logUberUserOut(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)

// MARK: Products 

public func fetchProductsForLocation(latitude latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)

public func fetchProductsForLocation(location: CLLocation, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)


public func createProduct(productID: String, completionBlock success: UberSingleProductSuccessBlock, errorHandler failure: UberErrorHandler?)

// MARK: - Estimates
public func fetchPriceEstimateForTrip(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)

public func fetchPriceEstimateForTrip(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)


public func fetchTimeEstimateForLocation(startLatitude startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)

public func fetchTimeEstimateForLocation(location: CLLocation, productID: String? = nil, userID : String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)

// MARK: - Promotions
public func fetchPromotionsForLocations(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)

public func fetchPromotionsForLocations(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)

// MARK: - User Profile

public func createUserProfile(completionBlock success: UberUserSuccess, errorHandler failure: UberErrorHandler?)

// MARK: - User Activity
public func fetchActivityForUser(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)

public func fetchUserActivity(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)


public func fetchAllUserActivity(completionBlock success: UberAllActivitySuccessCallback, errorHandler failure: UberErrorHandler?)

// MARK: - Request
public func createRequest(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, productID: String, surgeView view: UIView, surgeID surge : String? = nil, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?) // The UIView is an NSView on the Mac SDK.

public func createRequest(startLocation: CLLocation, endLocation: CLLocation, productID: String, surgeView view: UIView, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?) // The UIView is an NSView on the Mac SDK.

public func createRequest(requestID: String, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)

public func cancelRequest(requestID: String, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)

public func mapForRequest(requestID: String, completionBlock success: UberMapSuccessBlock, errorHandler failure: UberErrorHandler?)

public func receiptForRequest(requestID: String, completionBlock success: UberRequestReceiptSuccessBlock, errorHandler failure: UberErrorHandler?)
```

### Error Handling
The `UberError` class is at the root of error handling in this SDK. Here is the UberError class header
```swift

/// A wrapper around an UberError that gets sent as JSON. It is a subclass of NSError so it may also be a wrapper around the NSError. Inspect the isRepresentingNSError property to determine whether to handle this as an error that Uber provided or an NSError.
class UberError: NSError {
/// Human readable message which corresponds to the client error.
public let errorMessage: String

/// Underscored delimited string.
public let errorCode: String

/// A hash of field names that have validations. This has a value of an array with member strings that describe the specific validation error.
public let fields: [NSObject : AnyObject]?

/// Use this property to determine whether the error is representing an NSError or an error generated from the Uber servers.
public let isRepresentingNSError: Bool

/// An optional URL response, will be populated if available to help for debugging purposes.
public var response: NSURLResponse?

public var description: String

}
```

The UberError class is a subclass of NSError. The isRepresentingNSError property will inform you whether the error was generated as a result of an NSError being raised by the Cocoa APIs (`true`) or if the error was generated by the API (`false`). If it was generated by the API, then the fields errorCode, fields and errorMessage will be filled by the JSON returned from the server. You can read more about errors generated by Uber at https://developer.uber.com/v1/api-reference/#request-response. Further, if the error was generated as a result of something going wrong with some network task then the response field will be filled for debugging purposes too. 

### Miscellaneous

- All languages supported by the Uber API are supported by this SDK. Before making any calls change the language variable on the manager with a different language from the `Language` enum. The default value is English.
- Synchronicity can be achieved with the help of `NSLock` or even `dispatch_semaphore_t`. Here's an example of how we can take the asynchronous methods provided by this SDK and make them syncronous using NSLock, a similar implementation can be done with semaphores. Warning this should only be done on a background thread, doing this on the main thread will cause UI lag.
```swift
class Some: NSObject
{
let lock = NSLock()
func doMultipleThingsSynchronously()
{
// First let's get onto a background thread as mentioned before. 
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { 
	lock.lock()
	var some: UberProduct?

	// Now perform a request to fetch the uber product. 
	fetchProductsForLocation(location: someCLLocationInstance, completionBlock: { product in 
	defer { lock.unlock() }
	some = products.first // If there are no products we handle that later by returning.
}, errorHandler: { error in
	defer { lock.unlock() }
	print(error)
})	
	lock.lock()
	guard let some = some
	else
	{
		// An error occured, let's return. 
		return
	}
	// Now use some (which is a product for a different request like creating a request.
	// This should be trivial to implement now.
})
}
}
```

## Final Notes
- If you want to contribute some code (or even some test cases) make a new pull request.
- If you have a bug to report or want a new feature or a function you think the SDK should give developers access to create a new issue, in the issue tracker.
- Feel free to fork, star or clone this repo if you like it. I will be updating this frequently to include new functions that allow you to quickly access the API's endpoints.
