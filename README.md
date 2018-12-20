# SteamController

Drop-in support for Steam Controllers for iOS and tvOS.

For information about how to use a Steam Controller in Bluetoth LE mode, see [Steam Controller BLE](https://support.steampowered.com/kb_article.php?ref=7728-QESJ-4420#switch).

## Example

To run the example project, clone the repo, and run the SteamControllerTestApp target.

![Screenshot](screenshot.png)

In the example app, power on your controller (in BLE or BLE pairing mode) and press Scan. Connected controllers will appear in the list, and the UI will reflect the state of the controller. Tapping on a controller from the list will play the  "identify" melody on that controller.

## Requirements

* iOS 12 (might work on earlier versions, haven't tested).
* Steam Controller with BLE firmware.
* A game supporting MFi controllers using the `GameController` framework.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```
To integrate SteamController into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'SteamController'
```

Then, run the following command:

```bash
$ pod install
```

### Carthage

[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency manager that builds your dependencies and provides you with binary frameworks.

You can install Carthage with [Homebrew](http://brew.sh/) using the following command:

```bash
$ brew update
$ brew install carthage
```

To integrate SteamController into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "zydeco/SteamController"
```

Run `carthage update` to build the framework and drag the built `SteamController.framework` into your Xcode project.

## Usage

Everything should work like with MFi controllers. Depending on how your game works, you might not need any changes at all.

* `#import <SteamController/SteamController.h>`.
* To scan for Steam Controllers, call `[[SteamControllerManager sharedManager] scanForControllers]`.
* The framework will post `GCControllerDidConnectNotification` and `GCControllerDidDisconnectNotification`, as with MFi controllers.
* Connected Steam Controllers will be returned in `[GCController controllers]`.
* Controllers are a subclass of `GCController` that implements the `extendedGamepad` profile.
* Buttons on the Steam Controller are mapped to the extended gamepad profile as follows:
    * Analog stick: d-pad
    * Trackpads: thumbsticks
        * They report their position when touched
        * Return to 0,0 when released
    * A, B, X, Y: equivalent
    * Bumpers: L1/R1 shoulder buttons
    * Triggers: L2/R2 shoulder button/trigger
    * Start button: pause button
    * The rest of the inputs are not mapped:
        * Left/right grip
        * Gryo
        * Back
        * Steam Button
        * Analog stick click
        * Trackpad clicks

## License

SteamController is available under the MIT license. See the LICENSE file for more info.
