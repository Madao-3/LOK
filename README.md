#LOK

![LOK](https://img.shields.io/badge/LOK-0.0.1-red.svg)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)
![iOS](https://img.shields.io/badge/platform-iOS-LOK.svg)
![OSX](https://img.shields.io/badge/platform-OSX-LOK.svg)


## A lightweight and powerful iOS/OSX network library to make your debugging easier.

LOK can analyze all your request with a single line code.
```objc
[[LOKServer shareServer] setServerStart:YES];
```


![analyze all your request](http://ww2.sinaimg.cn/large/94053c2dgw1ezs5od47l4j20xc0gv77b.jpg)

## Features

* analyze all of your http/https requests
* analyze your cpu/memory/fps (works in iOS)
* only one line is needed to make the service work.

## Installation
To integrate LOK into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
group :development do
  gem "LOK"
end
```

Then, run the following command:

```bash
$ pod install
```

## Usage

```objc
[[LOKServer shareServer] setServerStart:YES];
```

The default port is 12345. You can also customize the port number:

```objc
 [[LOKServer shareServer] setServerStartWithPort:`<#(NSInteger)#>`]
```

If you are using the emulator, you can access the monitoring at `http://localhost:12345`.

When the app launches, the url will be copied to the pasteboard.

## Get in touch!

If you're using LOK, I'd love to hear from you. Drop me a line and tell me what you think!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
