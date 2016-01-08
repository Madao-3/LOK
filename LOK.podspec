Pod::Spec.new do |s|
  s.name         = "LOK"
  s.version      = "0.1"
  s.version      = "0.0.1"
  s.summary      = "LOK - a powerful iOS network debug library and make you debug easier."
  s.homepage     = "https://github.com/Madao-3/LOK"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

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