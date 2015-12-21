Pod::Spec.new do |s|
  s.name         = "LOK"
  s.version      = "0.1"
  s.summary      = "LOK - a powerful iOS network debug library and make you debug easier."
  s.homepage     = "https://github.com/coderyi/NetworkEye"
  s.license      = "MIT"
  s.authors      = { "madao" => "madao@uniqueway.com" }
  s.source       = { :git => "https://github.com/Madao-3/LOK", :tag => "0.1" }
  s.frameworks   = 'Foundation', 'CoreGraphics', 'UIKit'
  s.library      = "sqlite3"
  s.platform     = :ios, '7.0'
  s.source_files = 'LOK/LOK/**/*.{h,m,png}'
  s.requires_arc = true
  s.dependency "FMDB/SQLCipher", "~> 2.5"
end