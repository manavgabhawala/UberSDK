# UberSDK for iOS and Mac OS X - Swift

This is an SDK for the new Uber API released in March 2015. This SDK allows developers to easily use the Uber API without having to worry about implementing any OAuth 2.0 or perform any Network Requests. This SDK supports all end points available at https://developer.uber.com/v1/endpoints/ as of the beginning of April 2015.

Added some support for changes made on April 21, 2015.

## Installation Instructions 
Coming Soon. (If you can't wait lookup importing Dynamic Frameworks into Swift/Objective-C projects depending on what you are using.

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
	}, errorHandler: {(uberError, response, error) in 
		println(uberError)
		println(error)
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

```
#####Objective C
```objc

```

/**
Use this function to log an Uber user out of the system and remove all associated cached files about the user.

-
completionBlock: The block of code to execute once we have successfully logged a user out.
-
errorHandler:    An error occurred while loggin the user out. Handle the error in this block.
*/
public func logUberUserOut(completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to fetch uber products for a particular latitude and longitude `asynchronously`.

-
latitude:  		The latitude for which you want to find Uber products.
-
longitude: 		The longitude for which you want to find Uber products.

-
completionBlock: The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.

-
errorHandler:   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
*/
public func fetchProductsForLocation(latitude latitude: Double, longitude: Double, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch uber products for a particular location `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.

-
location: 		The location for which you want to find Uber products.

-
completionBlock: The block to be executed if the request was successful and we were able to parse the products. This block takes one parameter, an array of UberProducts. See the `UberProduct` class for more details on how this is returned.

-
errorHandler:  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
*/
public func fetchProductsForLocation(location: CLLocation, completionBlock success: UberProductSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to communicate with the Uber Product Endpoint. You can create an `UberProduct` wrapper using just the productID.

-
productID: The productID with which to create a new `UberProduct`
-
success:   The block of code to execute if we successfully create the `UberProduct`
-
failure:   The block of code to execute if an error occurs.

*:warning:* Product IDs are different for different regions. Fetch all products for a location using the `UberManager` instance.
*/
public func createProduct(productID: String, completionBlock success: UberSingleProductSuccessBlock, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to fetch price estimates for a particular trip between two points as defined by you `asynchronously`.

-
startLatitude:  	The starting latitude for the trip.
-
startLongitude: 	The starting longitude for the trip.
-
endLatitude:    	The ending latitude for the trip.
-
endLongitude:   	The ending longitude for the trip.

-
completionBlock: The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.

-
errorHandler:   	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.

:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
*/
public func fetchPriceEstimateForTrip(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch price estimates for a particular trip between two points `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitudes and longitudes.

-
startLocation: 	The starting location for the trip
-
endLocation:   	The ending location for the trip

-
completionBlock: The block to be executed if the request was successful and we were able to parse the price estimates. This block takes one parameter, an array of UberPriceEstimates. See the `UberPriceEstimate` class for more details on how this is returned.

-
errorHandler:  	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.

:warning: This function will report errors for points further away than 100 miles. Please make sure that you are asserting that the two locations are closer than that for best results.
*/
public func fetchPriceEstimateForTrip(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPriceEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to fetch time estimates for a particular latitude and longitude `asynchronously`. Optionally, add a productID and/or a userID to narrow down the search results.

-
startLatitude:   The starting latitude of the user.
-
startLongitude:  The starting longitude of the user.
-
userID:         	An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.
-
productID:       An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
-
completionBlock: The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.
-
errorHandler:   This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
*/
public func fetchTimeEstimateForLocation(startLatitude startLatitude: Double, startLongitude: Double, userID: String? = nil, productID: String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch time estimates for a particular latitude and longitude `synchronously`. Optionally, add a productID and/or a userID to narrow down the search results. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.

-
location:  		The location of the user.
-
productID: 		An optional parameter: a specific product ID which allows you to narrow down searches to a particular product.
-
userID:    		An optional parameter: the user's unique ID which allows you to improve search results as defined in the Uber API endpoints.

-
completionBlock: The block to be executed if the request was successful and we were able to parse the time estimates. This block takes one parameter, an array of UberTimeEstimates. See the `UberTimeEstimate` class for more details on how this is returned.

-
errorHandler: 	This block is called if an error occurs. This block takes two parameters the NSURLResponse for the request and the NSError generated because of the failed connection attempt.
*/
public func fetchTimeEstimateForLocation(location: CLLocation, productID: String? = nil, userID : String? = nil, completionBlock success: UberTimeEstimateSuccessBlock, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`.

-
startLatitude:  	The starting latitude of the user.
-
startLongitude: 	The starting longitude of the user.
-
endLatitude:    	The ending latitude for the travel.
-
endLongitude:   	The ending longitude for the travel.
-
completionBlock: The block of code to execute if an UberPromotion was successfully created. This block takes one parameter the `UberPromotion` object.
-
errorHandler:   	The block of code to execute if an error occurs.
*/
public func fetchPromotionsForLocations(startLatitude startLatitude: Double, startLongitude: Double, endLatitude: Double, endLongitude: Double, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch promotions for new users for a particular start and end locations `asynchronously`. If you are using CoreLocation use this function to pass in the location. Otherwise use the actual latitude and longitude.

-
startLocation: 	The starting location of the user.
-
endLocation:   	The ending location for the travel.
-
completionBlock: The block of code to execute if an UberPromotion was successfully created. This block takes one parameter the `UberPromotion` object.
-
errorHandler:  	The block of code to execute if an error occurs.
*/
public func fetchPromotionsForLocations(startLocation startLocation: CLLocation, endLocation: CLLocation, completionBlock success: UberPromotionSuccessBlock, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to `asynchronously` create an Uber User. The uber user gives you access to the logged in user's profile.

-
completionBlock: The block of code to execute if the user has successfully been created. This block takes one parameter an `UberUser` object.
-
errorHandler:    The block of code to execute if an error occurs.
*/
public func createUserProfile(completionBlock success: UberUserSuccess, errorHandler failure: UberErrorHandler?)
}

extension UberManager {
/**
Use this function to fetch a user's activity data `asynchronously`. This interacts with the v1.1 of the History endpoint and requires the HistoryLite scope.

-
offset:           Offset the list of returned results by this amount. Default is zero.
-
limit:            Number of items to retrieve. Default is 5, maximum is 50.
-
completionBlock:  The block of code to execute on success. The parameters to this block is an array of `UberActivity`, the offset that is passed in, the limit passed in, the count which is the total number of items available.
-
errorHandler:     The block of code to execute on failure.
*/
public func fetchActivityForUser(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch a user's activity data `asynchronously` for v 1.2. It requires the History scope.

-
offset:  Offset the list of returned results by this amount. Default is zero.
-
limit:   Number of items to retrieve. Default is 5, maximum is 50.
-
success: The block of code to execute on success. The parameters to this block is an array of `UberActivity`, the offset that is passed in, the limit passed in, the count which is the total number of items available.
-
failure: The block of code to execute on failure.

See the `fetchAllUserActivity` function for retrieving all the user's activity at one go.
*/
public func fetchUserActivity(offset offset: Int = 0, limit: Int = 5, completionBlock success: UberActivitySuccessCallback, errorHandler failure: UberErrorHandler?)

/**
Use this function to fetch a user's activity data `asynchronously` for v 1.2. It requires the History scope. This function will return all the user's activity after retrieving all of it without any limits however may take longer to run. If you want tor retrieve a smaller number of results and limit and offset the results use the fetchUserActivity:offset:limit: function.

-
success: The block of code to execute on success. The parameters to this block is an array of `UberActivity`
-
failure: The block of code to execute on failure.

See the `fetchUserActivity` function for retrieving a few values of the user's activity.
*/
public func fetchAllUserActivity(completionBlock success: UberAllActivitySuccessCallback, errorHandler failure: UberErrorHandler?)


/**
Use this function to communicate with the Uber Request Endpoint. You can create an `UberRequest` wrapper using just the requestID. You must have authenticated the user with the Request scope before you can use this endpoint.

-
requestID: 		The requestID with which to create a new `UberRequest`
-
completionBlock: The block of code to execute if we successfully create the `UberRequest`
-
errorHandler:    The block of code to execute if an error occurs.

*/
public func createRequest(requestID: String, completionBlock success: UberRequestSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to cancel an Uber Request whose request ID you have but do not have the wrapper `UberRequest` object. If you have an `UberRequest` which you want to cancel call the function `cancelRequest:` by passing its id.

-
requestID: 		The request ID for the request you want to cancel.
-
completionBlock: The block of code to execute on a successful cancellation.
-
errorHandler:    The block of code to execute on a failure to cancel the request.
*/
public func cancelRequest(requestID: String, completionBlock success: UberSuccessBlock?, errorHandler failure: UberErrorHandler?)

/**
Use this function to get the map for an Uber Request whose request ID you have.

-
requestID: 		 The request ID for the request whose map you want.
-
completionBlock:  The block of code to execute on a successful fetching of the map.
-
errorHandler:     The block of code to execute if an error occurs.
*/
public func mapForRequest(requestID: String, completionBlock success: UberMapSuccessBlock, errorHandler failure: UberErrorHandler?)

/**
Use this function to get a receipt for an Uber Request whose request ID you have.

- 
requestID The request ID for the request whose receipt
-
success   The block of code to execute on a successful fetching of the receipt.
-
failure   The block of code to execute if an error occurs.
*/
public func receiptForRequest(requestID: String, completionBlock success: UberRequestReceiptSuccessBlock, errorHandler failure: UberErrorHandler?)
```

### Error Handling
The `UberError` class is at the root of error handling in this SDK. Here is the UberError class header
```swift
/**
A wrapper around an UberError that gets sent as JSON. It is a subclass of NSError so it may also be a wrapper around the NSError. Inspect the isRepresentingNSError property to determine whether to handle this as an error that Uber provided or an NSError.
*/
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

The UberError class is a subclass of NSError. The isRepresentingNSError property will inform you whether the error was generated as a result of an NSError being raised by the Cocoa APIs (true) or if the error was generated by the API (false). If it was generated by the API, then the fields errorCode, fields and errorMessage will be filled by the JSON returned from the server. You can read more about errors generated by Uber at https://developer.uber.com/v1/api-reference/#request-response. Further, if the error was generated as a result of something going wrong with some network task then the response field will be filled for debugging purposes too. 

### Miscellaneous

- All languages supported by the Uber API are supported by this SDK. Before making any calls change the language variable on the manager with a different language from the `Language` enum. The default value is English.

## Final Notes
- If you want to contribute some code (or even some test cases) make a new pull request.
- If you have a bug to report or want a new feature or a function you think the SDK should give developers access to create a new issue, in the issue tracker.
- Feel free to fork this repo if you like it. I will be updating this frequently to include new functions that allow you to quickly access the API's endpoints.
