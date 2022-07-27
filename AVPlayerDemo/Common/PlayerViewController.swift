//
//  PlayerViewController.swift
//  AVPlayerMesh

import UIKit
import AVKit
import AVFoundation

#if MESH
import LumenAVMeshPlugin
#else
import LumenAVOrchestratorPlugin
#endif

//private let MANIFEST_URL = "http://wowza-test-cloudfront.streamroot.io/vodOrigin/tos1500.mp4/playlist.m3u8" //vod
private let MANIFEST_URL = "https://wowza-test-cloudfront.streamroot.io/liveOriginTimestamps/bbb_30fps_live.smil/playlist.m3u8" // live

extension AppDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    LMDeliveryClientPlugin.initializeApp()
    return true
  }
}

class PlayerViewController: UIViewController {
  private var avpController = AVPlayerViewController()
  private var plugin: LMDeliveryClientPlugin?
  private var airplayManager: LMAirplayManager!
  private var statView: UIView?
  private var statViewController: UIViewController!
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
      
    // Setup AVPlayerViewController view
    avpController.view.frame = self.view.bounds
    self.view.addSubview(avpController.view)
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    // add this line to turn off DefaultAirplayNotification inside our Plugin first
    self.plugin?.turnOffDefaultAirplayNotification()

    airplayManager = LMAirplayManager(delegate: self)
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)
    plugin?.stop()
    plugin = nil
  }
}

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
        o.meshProperty("classic")
      }
#else
      .orchestratorOptions { o in
        o.logLevel(.trace)
        o.orchestratorProperty("classic")
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
