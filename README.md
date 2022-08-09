# Lumen Delivery Client plugin for AVPlayer

Holds AVPlayer plugin for Mesh and CDN Load Balancer products.
This README holds public usage.
For internal/custom usage, see [this](docs/README.md).

## Prerequisites

To integrate this plugin, we need:

- A valid delivery client key. It is available in the Account section of your dashboard
- The Bundle Identifier of your application needs to have been allowed by our team
- Plugin Framework installed

## Framework installation

The plugin can be used through package managers (cocoapods/carthage) or directly added to a project by cloning this repository. This sections covers pods and carthage.

### Cocoapods

Mesh and CDN Load Balancer are published to two different pods. 
Depending on the product you need, add the following line to your Podfile for your target.

For Mesh :
```ruby
target 'MyApp' do
  use_frameworks!
  pod 'LumenMeshAVPlayerPlugin'
end
```
For CDN Load Balancer :
```ruby
target 'MyApp' do
  use_frameworks!
  pod 'LumenCDNLoadBalancerAVPlayerPlugin'
end
```

Then, execute `pod install`

### Carthage

```
github "streamroot/lumen-delivery-client-plugin-avplayer" "VERSION"
```

Since the plugin uses pods, after carthage checkout you need to run pod install inside the "lumen-delivery-client-plugin-avplayer" repository before continuing with carthage update.

## Configuration

### Disable App Transport security
In the Project Navigator, right click on "Info.plist", and "Open as" → "Source Code".
Add the following lines with the right parameters values.

```xml
<key>NSAppTransportSecurity</key>
<dict>
	<key>NSAllowsArbitraryLoads</key>
	<true/>
</dict>
```

### Set the DeliveryClient key
In the Project Navigator, right click on "Info.plist", and "Open as" → "Source Code".
Add the following lines with the right parameters values.

```xml
<key>DeliveryClient</key>
<dict>
  <key>Key</key>
  <string>customerKey</string>
</dict>
```

We strongly recommand to set the delivery client key in `Info.plist`. However, if not possible, it is also possible to pass your delivieryClientKey during the initialization step.

## Code integration

First, import the SDK:
```swift
// For Mesh
#import LumenMeshAVPlayerPlugin

// For CDN Load Balancer
#import LumenCDNLoadBalancerAVPlayerPlugin
```

### SDK Initialization

Initialize the Delivery SDK from the `AppDelegate`

```swift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    /*
     * If you can not add your deliveryClientKey in Info.plist
     * Call instead: LMDeliveryClientPlugin.initializeApp(withDeliveryKey: "MY_DELIVERY_CLIENT_KEY")
     */
    LMDeliveryClientPlugin.initializeApp()
    ...
  }

  ...
}
```

### Using the plugin for your url

The plugin automatically links your player with our SDK. It uses a restricted Builder pattern.
At the end of the construction it sets the right AVPlayerItem on the AVPlayer instance.
Our SDKs are using a proxy which means the url AVPlayer is working with is not your original url. 
The final url can be found in a field of the plugin object : `plugin.finalUri`.

**Smallest usage :**

```swift
plugin = LMDeliveryClientPlugin.newBuilder(uri: manifestUrl)
      .createAVPlayer()
      .start()
```

In the previous example, the plugin is in charge of :
- creating an AVPlayer instance
- setting the AVPlayerItem with the correct url
- creating our SDK
- linking our SDK with the player
- starting our SDK

You are still responsible for :
- Linking the player with your UI (`avpController.player = plugin.avPlayer`)
- Starting the playback (`plugin.avPlayer.play()`)

Make sure you keep a strong reference to the plugin in your UIViewController.

**Advanced :**

You may prefer to give us your own AVPlayer :

```swift
plugin = LMDeliveryClientPlugin.newBuilder(uri: manifestUrl)
      .avPlayer(MY_AVPLAYER)
      .start()
```

## Additional options

You can pass additional options during the creation of a `LMDeliveryClientPlugin`

### Mesh

<details><summary>Mesh</summary>

````swift
plugin = LMDeliveryClientPlugin.newBuilder(uri: manifestUrl)
      .createAVPlayer()
      .meshOptions { o in
        /*
          * Set Mesh property
          *
          * param: String
          */
        o.meshProperty("MY_PROPERTY")
        /*
          * Set the content id
          * A string that identifies your content
          * By default, it uses the stream url
          *
          * param: String
          */
        o.contentId("MY_CONTENT_ID")
        /*
          * Set the log level
          * See the "How to investigate?" to know more
          *
          * param: LumenLogLevel
          */
        o.logLevel(.info)
        /*
           * Set latency in seconds
           *
           * param: Int
           */
        o.latency(3)
        /*
          * Set a proxy server
          * Allows the use of a proxy server in the middle
          * Format is host:port
          *
          * params: String
          */
        o.proxyServer("MY_PROXY_HOST:PORT")
      }.start()
````
</details>

### CDN Load Balancer

<details><summary>CDN Load Balancer</summary>

````swift
plugin = LMDeliveryClientPlugin.newBuilder(uri: manifestUrl)
      .createAVPlayer()
      .orchestratorOptions { o in
        /*
          * Set Orchestrator property
          *
          * param: String
          */
        o.orchestratorProperty("MY_PROPERTY")
        /*
          * Set the content id
          * A string that identifies your content
          * By default, it uses the stream url
          *
          * param: String
          */
        o.contentId("MY_CONTENT_ID")
        /*
          * Set the log level
          * See the "How to investigate?" to know more
          *
          * param: LumenLogLevel
          */
        o.logLevel(.info)
        /*
          * Set a proxy server
          * Allows the use of a proxy server in the middle
          * Format is host:port
          *
          * params: String
          */
        o.proxyServer("MY_PROXY_HOST:PORT")
      }.start()
````
</details>

## How to investigate? Make sure the integration is working?

### Enable logs
By default the log level is set to `OFF`, it can be overriden during the `LMDeliveryClientPlugin` creation:
````swift
plugin = LMDeliveryClientPlugin.newBuilder(uri: manifestUrl)
      .createAVPlayer()
      .meshOptions { o in // OR .orchestratorOptions { o in
        o.logLevel(.trace)
      }.start()
````

### StatsView
A helper method is available to display various Mesh/CDN Load Balancer related stats on a specified UIView.

````swift
// The implementer is in charge of creating the view and to displaying it on top of the player controller/layer
plugin.displayStatsView(someView!)
````
# How to integrate seamlessly with AirPlay
AirPlay is a protocol that allows wireless streaming between devices of audio, video, device screens, and photos, together with related metadata. Using this protocol, it is possible to view your media content on other devices compatible with Apple.

## Background
If you are using Lumen SDK on your mobile device or any other apple device and wish to stream your content on any other device such as Apple TV, it is important to follow certain procedures in order to not break your playback.

This is because Lumen (Streamroot) operates as a proxy which hides visibility of the URL of the media content from your device to any other apple device such as Apple TV. The media content URL is converted to a local URL to talk to our proxy. The resulting URL is then a local host URL (Eg: https://localhost:888/).

This URL cannot be read by the device you are trying to stream to since its a local URL. As a result, playback will not begin and you won't be able to stream your media content.

The original URL has to be provided to the device you are trying to cast to in order to stream your media content.
## Solution
You can use the following proposition while using Airplay.
When the viewer switch from iOS device to Airplay, you need to provide the plugin a new AVPlayer
The Proxy will be stopped when Airplay is used. When the playback returned to iOS device, the Proxy will be started again.

### Suggest implementation
In your PlayerViewController class:

-Add a `private var airplayManager: LMAirplayManager!`

-Turn off the default Airplay Notification inside our Plugin and Init the airplayManager in `viewDidAppear(` method
`self.plugin?.turnOffDefaultAirplayNotification()`
`airplayManager = LMAirplayManager(delegate: self)`

-Add an extension of `PlayerViewController` to handle `onAirplayEnabled()` and `onAirplayDisabled()` events (as follow:)

    extension PlayerViewController : LMAirplayManagerDelegate {
      func onAirplayEnabled() -> (avPlayerWithItem: AVPlayer, autoplay: Bool) {
        statView?.removeFromSuperview()
        plugin = nil

        let avPlayerWithItem = AVPlayer(url: URL(string: MANIFEST_URL)!)
        avpController.player = avPlayerWithItem
        return (avPlayerWithItem: avPlayerWithItem, autoplay: true)
      }

      func onAirplayDisabled() -> (plugin: LMDeliveryClientPlugin, autoplay: Bool) {
        // Create and start a delivery client
        self.plugin = LMDeliveryClientPlugin.newBuilder(uri: URL(string: MANIFEST_URL)!)
          .createAVPlayer()
    #if MESH
          .meshOptions { o in
            o.logLevel(.trace)
            o.meshProperty("classic") // put your orch Mesh here
          }
    #else
          .orchestratorOptions { o in
            o.logLevel(.trace)
            o.orchestratorProperty("classic") // put your orch Property here
          }
    #endif
          .start()
        avpController.player = plugin!.avPlayer

        /* Setup stat view
         * AVPlayerViewController propose `contentOverlayView` to enrich
         * the view with additional content. However, it does not support
         * user interaction.
         *
         * We recommand to add the stat view as a subview instead and once
         * the player is started.
         */
        statView = UIView(frame: self.view.bounds)
        avpController.view.addSubview(statView!)
        plugin!.displayStatsView(statView!)

        return (plugin: plugin!, autoplay: true)
      }
    }
