# UberSDK for iOS and Mac OS X - Swift

This is an SDK for the new Uber API released in March 2015. This SDK allows developers to easily use the Uber API without having to worry about implementing any OAuth 2.0 or perform any Network Requests. This SDK supports all end points available at https://developer.uber.com/v1/endpoints/ as of the beginning of April 2015.

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
var scopes : NSArray { get { return [UberScopes.Profile.rawValue, UberScopes.Request.rawValue] } }
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

@property (nonatomic, readonly) NSArray * __nonnull scopes;

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
let manager = UberManager(applicationName: "APP_NAME", clientID: "CLIENT_ID", clientSecret: "CLIENT_SECRET", serverToken: "SERVER_TOKEN", redirectURI: "REDIRECT_URI", baseURL: .SandboxAPI, scopes: [.Profile, .Request])
}

}
```
#####Objective C
```objc
NSArray *scopes = [[NSArray alloc] initWithObjects:UberScopesProfile, UberScopesRequest, nil];
UberManager *manager = [[UberManager alloc] initWithApplicationName:@"APP_NAME"
clientID:@"CLIENT_ID"
clientSecret:@"CLIENT_SECRET"
serverToken:@"SERVER_TOKEN"
redirectURI:@"REDIRECT_URI"
baseURL:UberBaseURLSandboxAPI
scopes:scopes];
```
### User Authentication with OAuth 2.0
Once you have initialized the `UberManager` instance, you must get a user to log in before you can use any of the endpoints that require User Authentication. These include:
- Fetching a User's Profile
- Fetching a User's Activity History
- Creating, Cancelling and Viewing a User's Requests

Before calling any of these functions you must call `performUserAuthorization(completionBlock:errorHandler:)` on your `UberManager` instance. In an iOS App we will present a `UIWebView` on the `keyWindow` and ask the user to login with the `UberScopes` you provided. On a Mac App we do the same thing except with a `WKWebView`. All the nitty grittys of implementing the OAuth2.0 has been done for you including saving an encrypted `access_token`, `refresh_token` and `expiration` to the disk. Further, the `WebView` gets dismissed automatically, too. If the user logs in the completionBlock will get executed else the errorHandler block will get executed with an `UberError`, an `NSURLResponse` and an `NSError` as parameters. Look at `UberErrorHandler` for more details on error handlers. Once the `completionBlock` is called you know that the user has successfully logged in and we have their access token. You can now call the other functions in the SDK to communicate with the API.
#####Swift 
```swift
manager.performUserAuthorization(completionBlock: { 
// Yay! The user is now logged in.
}, errorHandler: {(uberError, response, error) in 
println(uberError)
println(error)
// TODO: Some awesome error handling.
})  
```
#####Objective C
```objc
[manager performUserAuthorizationWithCompletionBlock:^() {
// Yay! The user is now logged in!
} errorHandler:^(UberError* uberError, NSURLResponse* response,
NSError* error){
// TODO: Some amazing error handling
}];
```
### Function Calls
Now, you can make all the function calls you like to access the API endpoints. Almost all of these functions are available in the UberManager class and have detailed header docs.
- [ ] Add descriptions and names of public functions in UberManager

There are a few exceptions, however. These functions made more logical sense to be in their respective classes and hence are in there. These function calls must also only be made after initializing the `UberManager`. Here is a list of functions available outside the `UberManager` class.
#####Swift
```swift
UberProduct.createProduct(productID: "SOME_PRODUCT_ID", success: {(product in
	println(product)
	// Created an UberProduct.
}, failure: {(uberError, response, error) in 
	println(uberError)
	println(error)
	// TODO: Some awesome error handling.
})
```
#####Objective C
```objc
[UberProduct createProduct:@"SOME_PRODUCT_ID"
completionBlock:^(UberProduct* product) {
	NSLog(@"%@", product);
	// Created an UberProduct.
}
errorHandler:^(UberError* uberError,
NSURLResponse* response, NSError* error){
	// TODO: Some awesome error handling.
}];

[UberProduct performUserAuthorizationWithCompletionBlock:^() {
// Yay! The user is now logged in!
} errorHandler:^(UberError* uberError, NSURLResponse* response,
NSError* error){
// TODO: Some amazing error handling
}];
```
### Miscellaneous

More detailed information coming soon.

## Final Notes
- If you want to contribute some code (or even some test cases) make a new pull request.
- If you have a bug to report or want a new feature or a function you think the SDK should give developers access to create a new issue, in the issue tracker.
- Feel free to fork this repo if you like it. I will be updating this frequently to include new functions that allow you to quickly access the API's endpoints.
