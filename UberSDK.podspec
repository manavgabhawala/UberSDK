Pod::Spec.new do |s|
  s.name         = "UberSDK"
  s.version      = "0.0.1"
  s.summary      = "A short description of UberSDK."

  s.description  = <<-DESC
                   This is an SDK for the new Uber API released in March 2015. This SDK allows developers to easily use the Uber API without having to worry about implementing any OAuth 2.0 or perform any Network Requests.
                   DESC

  s.homepage     = "https://github.com/manavgabhawala/UberSDK"

  s.license      = { :type => "Apache", :file => "LICENSE" }

  s.author             = { "Manav Gabhawala" => "manav1907@gmail.com" }
  s.social_media_url   = "https://twitter.com/manavgabhawala"

  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"

  s.source       = { :git => "https://github.com/manavgabhawala/UberSDK.git", :tag => s.version }

  s.source_files  = "Shared/*.{swift,h}", "UberiOSSDK/*.{h,swift}", "UberMacSDK/*.{swift,h}"

  s.public_header_files = "UberiOSSDK/*.h", "UberMacSDK/*.h"

  s.requires_arc = true

end
