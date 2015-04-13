# UberSDK for iOS and Mac OS X - Swift

This is an SDK for the new Uber API released in March 2015. This SDK allows developers to easily use the Uber API without having to worry about implementing any OAuth 2.0 or perform any Network Requests. This SDK supports all end points as of the beginning of April 2015.

## Installation Instructions 
Coming Soon. (If you can't wait lookup importing Swift Frameworks into Swift/Objective-C projects depending on what you are using

## Documentation and Usage 
The basic way to initialize the SDK is creating an instance of the `UberManager` object. You should create only one instance of the `UberManager` at a time. This instance is thread safe in that you can use the same instance on multiple threads but if you initialize a new UberManager your old UberManager will start accessing older properties. 
To initialize the `UberManager` You can either implement the `UberManagerDelegate` or pass in all the values required for the application setup to the init function. This includes the *client key*, *client secret*, *server token* and *redirectURI*. Then you can call functions on your instance of the manager.
Before calling any function that needs user OAuth2.0 you must call `performUserAuthorization(completionBlock:, errorHandler:)`.

More detailed information coming soon.

## Final Notes
- If you want to contribute some code (or even some test cases) make a new pull request.
- If you have a bug to report or want a new feature or a function you think the SDK should give developers access to create a new issue, in the issue tracker.
- Feel free to fork this repo if you like it. I will be updating this frequently to include new functions that allow you to quickly access the API's endpoints.
