# AV Player plugin - internal

This document is intended for :

- The team in charge of updating and publishing the plugins
- Integrators who neither want to use cocoapods nor carthage and want to link directly against the plugin

## Repository structure

### Xcode projects & Streamroot SDKs

This repository contains two Xcode projects backed by cocoapods :

- The AVPlugin project which contains all plugin sources and ultimately stands alone during publication
- The AVPlayerDemo project which references the AVPlugin products for instant testing

Mesh and CDN Load Balancer SDKs are imported into the projects as a cocoapods dependency.

### Targets

Each project contains four main targets :

- iOS x Mesh
- tvOS x Mesh
- iOS x CDN Load Balancer (AKA Orchestrator)
- tvOS x CDN Load Balancer (AKA Orchestrator)

The plugin project also contains unit testing target extensions.

### Differenciating Mesh & CDN Load Balancer

Mesh and CDN Load Balancer products has a lot of code in common. 
To avoid duplicating code and in order to remain DRY, a Swift flag called "MESH" is introduced in both projects.
Thus, preprocessor directives are used in source files to differentiate both.

## Running the Demo

### Installation

The projects makes use of cocoapods which is ruby gem. That dependency is defined in a Gemfile.

To install cocoapods run `bundle install`. The executable `pod` should now be available in your PATH.

The projects' dependencies are defined in the Podfile. To install them and complete setup, run `pod install`

Now either run `open avplugin.xcworkspace` or open the avplugin.xcworkspace in Xcode

### Running a target

Select the Demo scheme according to your need (iOS/tvOS, Mesh/CDN Load balancer) and run it.

### Customizing

All changes are to be made inside the PlayerViewController

- Change URL by changing MANIFEST_URL
- initializeApp step can be changed in the AppDelegate extension contained at the top
- Add any mesh/orchestrator options directly in the code

## Plugin : deep dive

### Sources

The plugin consists in two files :

- LMDeliveryClientPlugin, containing the SDK wrapper
- LMAVPlayerInteractor, containing the implementation of the bridge between AVPlayer and our SDKs

The plugin is built using a restricted Builder pattern that enforces mandatory steps on integration side.

It is wanted compact by shortcutting extra steps when possible.
```swift
LMDeliveryClientPlugin.newBuilder(uri: URL(string: MANIFEST_URL)!)
    .createAVPlayer()
    .meshOptions{o in }     // No mesh options
    .build()                // Build SDK and plugin
    .start()                // Start Mesh or CDN Load Balancer
```

Can be shortened to :
```swift
LMDeliveryClientPlugin.newBuilder(uri: URL(string: MANIFEST_URL)!)
    .createAVPlayer()
    .start()
```

The wrapped DeliveryClient is private and manipulation is done through redefinition of interfaces (start/stop/displayStatsView etc).

initializeApp is redefined as well so that direct SDK import is not required on integration side.

## Custom framework installation

For general cocoapods/carthage, please see [his](../README.md).

### Direct link (preferred)

A direct plugin link is the equivalent of what is done with the Demo project.
- You need to use cocoapods
- You need to add AVPlugin xcodeproj to your workspace and add the product of AVPlugin you need as a dependency of your personal xcodeproj.

### Framework link (unrecommended)

You can generate a standalone framework from the AVPlugin project.
It is not recommended :
- pre-compiled Swift sources may clash with other swift compilers as Xcode versions increase.
- it may desynchronize your project as the Framework is a snapshot of the plugin and you need to regenerate it as our SDKs get new updates

After generating the framework you can just add it to you project and embed it to you application.

## Release & versioning

Release is done by replacing the versions inside config.json, commiting and adding a new tag.
The plugin version contains 4 components : SDK_VERSION(3).PLUGIN_PATCH(1), ex : SDK 22.06.0 -> 22.06.0.0.

All these steps can be done automatically by running the publish script :
`./scripts/publish.sh SDK_VERSION PATCH_VERSION`
If arguments are missing, you will be prompted.

This scripts :
- Updates config.json
- Commits and tags with the plugin version
- runs pod spec lint
- runs pod trunk push for both CDN Load Balancer / Mesh delivery

Note : you need ownership on the pods to be able to push.

Carthage is decentralized so the new version is made available at tag publication step.