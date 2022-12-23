import AVFoundation
import Foundation
#if MESH
  import LumenMeshSDK
#else
  import LumenOrchestratorSDK
#endif

public typealias AVPlayerItemFactory = (_ finalUrl: URL) -> AVPlayerItem

public protocol AVPlayerBuilder {
  func createAVPlayer() -> AVPlayerItemBuilder
  func avPlayer(_ avPlayer: AVPlayer) -> AVPlayerItemBuilder
}

public protocol AVPlayerItemBuilder: ProductBuilder {
  func avPlayerItemFactory(_ factory: @escaping AVPlayerItemFactory) -> ProductBuilder
  func disableAVPlayerItemAutoSet() -> ProductBuilder
}

public class LMProductOptions {
  private let sdkOptions: LMOptions
  fileprivate init(sdkOptions: LMOptions) {
    self.sdkOptions = sdkOptions
  }

  @discardableResult public func contentId(_ contentId: String) -> LMProductOptions {
    sdkOptions.contentId(contentId)
    return self
  }

  @discardableResult public func deliveryClientKey(_ deliveryClientKey: String) -> LMProductOptions {
    sdkOptions.deliveryClientKey(deliveryClientKey)
    return self
  }

  @discardableResult public func logLevel(_ logLevel: LMLogLevel) -> LMProductOptions {
    sdkOptions.logLevel(logLevel)
    return self
  }

  @discardableResult public func proxyServer(_ proxyServer: String) -> LMProductOptions {
    sdkOptions.proxyServer(proxyServer)
    return self
  }

  #if MESH
    @discardableResult public func meshProperty(_ meshProperty: String) -> LMProductOptions {
      sdkOptions.meshProperty(meshProperty)
      return self
    }

    @discardableResult public func latency(_ latency: Int) -> LMProductOptions {
      sdkOptions.latency(latency)
      return self
    }
  #else
    @discardableResult public func orchestratorProperty(_ orchestratorProperty: String) -> LMProductOptions {
      sdkOptions.orchestratorProperty(orchestratorProperty)
      return self
    }
  #endif
}

public protocol ProductBuilder: PluginFinisher {
  #if MESH
    func meshOptions(_ optionCallback: (_ o: LMProductOptions) -> Void) -> PluginFinisher
  #else
    func orchestratorOptions(_ optionCallback: (_ o: LMProductOptions) -> Void) -> PluginFinisher
  #endif
}

public protocol PluginFinisher {
  func build() -> LMDeliveryClientPlugin
  func start() -> LMDeliveryClientPlugin
  func start(completion: @escaping () -> Void) -> LMDeliveryClientPlugin
}

public class LMDeliveryClientPlugin {
  public static func newBuilder(uri: URL) -> AVPlayerBuilder {
    return Builder(uri: uri)
  }

  class Builder: AVPlayerBuilder, AVPlayerItemBuilder, ProductBuilder, PluginFinisher {
    private let originalUri: URL

    private var avPlayer: AVPlayer!
    private var autosetPlayerItem: Bool = true
    private var avPlayerItemFactory: AVPlayerItemFactory?

    private var intermediateData: (
      item: AVPlayerItem,
      interactor: LMAVPlayerInteractor,
      deliveryClient: LMDeliveryClient
    )!

    fileprivate init(uri: URL) {
      originalUri = uri
    }

    // AV creation
    func createAVPlayer() -> AVPlayerItemBuilder {
      avPlayer = AVPlayer()
      return self
    }

    func avPlayer(_ avPlayer: AVPlayer) -> AVPlayerItemBuilder {
      self.avPlayer = avPlayer
      return self
    }

    // Disable autoset AV item
    func disableAVPlayerItemAutoSet() -> ProductBuilder {
      autosetPlayerItem = false
      return self
    }

    func avPlayerItemFactory(_ factory: @escaping (URL) -> AVPlayerItem) -> ProductBuilder {
      avPlayerItemFactory = factory
      return self
    }

    private func configureProduct(_ optionCallback: (_ o: LMProductOptions) -> Void) {
      let interactor = LMAVPlayerInteractor()
      let options = LMDeliveryClientBuilder.clientBuilder().playerInteractor(interactor)

      // Configure DC
      optionCallback(LMProductOptions(sdkOptions: options))

      // Create DC
      let deliveryClient = options.build(originalUri)

      // Resolve final url
      let finalUrl = deliveryClient.localManifestURL ?? originalUri

      // Resolve AVPlayerItem
      let item = avPlayerItemFactory?(finalUrl) ?? AVPlayerItem(url: finalUrl)

      // Link DC with player
      if autosetPlayerItem {
        avPlayer.replaceCurrentItem(with: item)
      }
      interactor.linkPlayer(avPlayer, playerItem: item)

      intermediateData = (item, interactor, deliveryClient)
    }

    #if MESH
      // Mesh
      func meshOptions(_ optionCallback: (_ o: LMProductOptions) -> Void) -> PluginFinisher {
        configureProduct(optionCallback)
        return self
      }
    #else
      // Orchestrator
      func orchestratorOptions(_ optionCallback: (_ o: LMProductOptions) -> Void) -> PluginFinisher {
        configureProduct(optionCallback)
        return self
      }
    #endif

    // Finisher
    func build() -> LMDeliveryClientPlugin {
      if intermediateData == nil {
        #if MESH
          _ = meshOptions { _ in }
        #else
          _ = orchestratorOptions { _ in }
        #endif
      }
      return LMDeliveryClientPlugin(originalUri: originalUri,
                                    avPlayer: avPlayer,
                                    avPlayerItem: intermediateData.item,
                                    interactor: intermediateData.interactor,
                                    deliveryClient: intermediateData.deliveryClient)
    }

    func start() -> LMDeliveryClientPlugin {
      let plugin = build()
      _ = plugin.start()
      return plugin
    }

    func start(completion: @escaping () -> Void) -> LMDeliveryClientPlugin {
      let plugin = build()
      _ = plugin.start(completion)
      return plugin
    }
  }

  internal let deliveryClient: LMDeliveryClient?
  private let interactor: LMAVPlayerInteractor
  public let originalUri: URL
  public let finalUri: URL
  public let avPlayer: AVPlayer
  public let avPlayerItem: AVPlayerItem

  private init(originalUri: URL,
               avPlayer: AVPlayer,
               avPlayerItem: AVPlayerItem,
               interactor: LMAVPlayerInteractor,
               deliveryClient: LMDeliveryClient?)
  {
    self.originalUri = originalUri
    self.avPlayer = avPlayer
    self.avPlayerItem = avPlayerItem
    self.interactor = interactor
    self.deliveryClient = deliveryClient
    finalUri = deliveryClient?.localManifestURL ?? originalUri
    setupAirplayDefaultNotification()
  }

  deinit {
    removeAirplayDefaultNotification()
  }

  // MARK: - Airplay support

  /// To detect actual airplay switch we can use the device audio output
  /// we need to register to AVAudioSession.routeChangeNotification
  private func setupAirplayDefaultNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioOutputDidChange),
      name: AVAudioSession.routeChangeNotification,
      object: AVAudioSession.sharedInstance()
    )
  }

  internal func removeAirplayDefaultNotification() {
    NotificationCenter.default.removeObserver(
      self,
      name: AVAudioSession.routeChangeNotification,
      object: AVAudioSession.sharedInstance()
    )
  }

  // This method is only called upon first Airplay switch
  @objc func audioOutputDidChange() {
    // Get the current audio route
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    // Check if the audio  output is an airplay type
    guard let airplayOutput = currentRoute.outputs.filter({ $0.portType == .airPlay }).first else {
      return
    }
    print("Airplay device name: \(airplayOutput.portName)")

    // Consume one shot notification
    removeAirplayDefaultNotification()

    // Save the current playbacktime
    let time = avPlayer.currentTime()

    // Create a player item with the original url
    let newItem = AVPlayerItem(url: originalUri)
    // Replace the player item to bypass local proxy
    avPlayer.replaceCurrentItem(with: newItem)

    // Seek to last saved time, especially helpful for VOD streams
    avPlayer.seek(to: time)

    deliveryClient?.stop()
  }

  @discardableResult public func start() -> LMDeliveryClientPlugin {
    deliveryClient?.start()
    return self
  }

  @discardableResult public func start(_ completion: @escaping () -> Void) -> LMDeliveryClientPlugin {
    deliveryClient?.start(completion: completion)
    return self
  }

  @discardableResult public func displayStatsView(_ view: UIView) -> LMDeliveryClientPlugin {
    deliveryClient?.displayStatView(view)
    return self
  }

  @discardableResult public func toggleStatsView() -> LMDeliveryClientPlugin {
    deliveryClient?.toggleStatView()
    return self
  }

  @discardableResult public func stop() -> LMDeliveryClientPlugin {
    deliveryClient?.stop()
    return self
  }

  @discardableResult public func stop(_ completion: @escaping () -> Void) -> LMDeliveryClientPlugin {
    deliveryClient?.stop(completion: completion)
    return self
  }
}

public extension LMDeliveryClientPlugin {
  static func initializeApp(completionHandler: ((Bool) -> Void)? = nil) {
    LMDeliveryClient.initializeApp(completionHandler: completionHandler)
  }

  static func initializeApp(withDeliveryKey: String, completionHandler: ((Bool) -> Void)? = nil) {
    LMDeliveryClient.initializeApp(withDeliveryKey: withDeliveryKey, completionHandler: completionHandler)
  }
}
