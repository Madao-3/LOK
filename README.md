#LOK

![LOK](https://img.shields.io/badge/LOK-0.0.1-red.svg)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)
![iOS](https://img.shields.io/badge/platform-iOS-LOK.svg)
![OSX](https://img.shields.io/badge/platform-OSX-LOK.svg)


## A small, lightweight, a powerful iOS/OSX network debug library and make you debug easier.

LOK can analyze all your request with a single line code.
> [[LOKServer shareServer] setServerStart:YES];


![analyze all your request](http://ww2.sinaimg.cn/large/94053c2dgw1ezs5od47l4j20xc0gv77b.jpg)

## Features


* analyze all your http/https request
* analyze your cpu/memory/fps(work in iOS)
* only one line can make the service work.

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

default port is 12345

also you can custom your port number:

```objc
 [[LOKServer shareServer] setServerStartWithPort:`<#(NSInteger)#>`]
```

if you use the simulator, you can open `http://localhost:12345`.

when the app launch,the url will copy to pasteboard.


## Get in touch!

If you're using LOK, I'd love to hear from you. Drop me a line and tell me what you think!

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request