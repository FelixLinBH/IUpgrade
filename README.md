# IUpgrade

[![Version](https://img.shields.io/cocoapods/v/IUpgrade.svg?style=flat)](http://cocoapods.org/pods/IUpgrade)
[![License](https://img.shields.io/cocoapods/l/IUpgrade.svg?style=flat)](http://cocoapods.org/pods/IUpgrade)
[![Platform](https://img.shields.io/cocoapods/p/IUpgrade.svg?style=flat)](http://cocoapods.org/pods/IUpgrade)

Notify new version of enterprise app is available.

It provides:

* Update mode **( Normal / Forec / Skip )**
* Customization alert message

## How To Use

### Set Plist URL

```
[[IUpgrade sharedInstance]setPlistUrlString:@"https://xxx.plist"];
```

### Set Type

```
// Normal.
[[IUpgrade sharedInstance]setType:IUpgradeDefault];
// Forec upgrade,it will swizzling appdelegate applicationWillEnterForeground.
[[IUpgrade sharedInstance]setType:IUpgradeForec];
// User can choose skip the version.
[[IUpgrade sharedInstance]setType:IUpgradeSkip];
```

### Set Message

####Properties####

```
@property (nonatomic) NSString *alertTitle;
@property (nonatomic) NSString *prefixMessage;
@property (nonatomic) NSString *suffixMessage;
```
####Method####

```
[[IUpgrade sharedInstance]setAlertTitle:@"Title" prefixMessage:@"prefix" suffixMessage:@"suffix"];
```

It will show message that **"prefix version suffix"**.

### Check version
**After main view makeKeyAndVisible.**

```
[[IUpgrade sharedInstance]checkVersion];
```

### Screen shot

![Editor preferences pane](https://github.com/FelixLinBH/IUpgrade/blob/master/ScreenShot.png?raw=true)


## Installation

IUpgrade is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "IUpgrade"
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

[Felix.lin](mailto:fly_81211@hotmail.com)

## License

IUpgrade is available under the MIT license. See the LICENSE file for more info.
