Pod::Spec.new do |s|
  s.name         = "LOK"
  s.version      = "0.0.1"
  s.summary      = "LOK - a powerful iOS network debug library and make you debug easier."
  s.homepage     = "https://github.com/Madao-3/LOK"
  s.screenshots  = "https://camo.githubusercontent.com/e4f7e70e3f6427e0c259f89f1f3fcadbfaa27971/687474703a2f2f7777322e73696e61696d672e636e2f6c617267652f3934303533633264677731657a73356f6434376c346a323078633067763737622e6a7067"

  s.license          = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author           = "Madao"
  s.social_media_url = "https://twitter.com/madao_chris/"
  s.platform         = :ios, "7.0"
  s.source           = { :git => "https://github.com/Madao-3/LOK", :tag => "0.0.1" }
  s.source_files     = 'Core/**/*.{h,m}'
  s.resource_bundles = {
    'WebSite' => ['Core/WebSite.bundle/*']
  }
  s.requires_arc     = true
  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  s.frameworks = "QuartzCore"
  s.dependency 'RoutingHTTPServer', '~> 1.0'
  s.dependency 'PocketSocket', '~> 0.6.4'
end