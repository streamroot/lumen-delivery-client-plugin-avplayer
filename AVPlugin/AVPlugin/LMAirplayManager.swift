//
//  LMAirplayManager.swift
//  AVPlugin

import Foundation
import AVKit

public protocol LMAirplayManagerDelegate : NSObject {
  func onAirplayEnabled() -> (avPlayerWithItem: AVPlayer, autoplay: Bool)
  func onAirplayDisabled() -> (plugin: LMDeliveryClientPlugin, autoplay: Bool)
}

public class LMAirplayManager {
  private weak var delegate: LMAirplayManagerDelegate?
  private var plugin: LMDeliveryClientPlugin?
  private var currentPlayer: AVPlayer?
  private var wasOnAirplay: Bool? = nil
  
  public init(delegate: LMAirplayManagerDelegate) {
    self.delegate = delegate
    plugin = nil
    currentPlayer = nil
    registerAirplayNotification()
    audioOutputDidChange()
  }
  
  deinit {
    unregisterAirplayNotification()
  }
  
  private func registerAirplayNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(audioOutputDidChange),
      name: AVAudioSession.routeChangeNotification,
      object: AVAudioSession.sharedInstance())
  }
  
  private func unregisterAirplayNotification() {
    NotificationCenter.default.removeObserver(
      self,
      name: AVAudioSession.routeChangeNotification,
      object: AVAudioSession.sharedInstance())
  }
  
  @objc private func audioOutputDidChange() {
    let time = self.currentPlayer?.currentTime()
    guard let delegate = delegate else { return }
    
    func seekAndPlay(autoplay: Bool) {
      if let _ = currentPlayer!.currentItem {
        if let time = time {
          currentPlayer!.seek(to: time)
        }
        if autoplay {
          currentPlayer!.play()
        }
      } else {
        print("Lumen: No AVPlayerItem loaded in Airplay change")
      }
    }
    
    let isPlayingOnAirplay = isPlayingOnAirplay()
    guard isPlayingOnAirplay != wasOnAirplay else { return }
    wasOnAirplay = isPlayingOnAirplay

    if isPlayingOnAirplay {
      let newConfig = delegate.onAirplayEnabled()
      currentPlayer = newConfig.avPlayerWithItem
      plugin?.stop()
      plugin = nil
      seekAndPlay(autoplay: newConfig.autoplay)
    } else {
      let newConfig = delegate.onAirplayDisabled()
      plugin = newConfig.plugin
      currentPlayer = newConfig.plugin.avPlayer
      seekAndPlay(autoplay: newConfig.autoplay)
    }
  }
  
  private func isPlayingOnAirplay() -> Bool {
    let currentRoute = AVAudioSession.sharedInstance().currentRoute
    guard let airplayOutput = currentRoute.outputs.filter({$0.portType == .airPlay}).first else {
      // NOT AirPlay
      return false
    }
    print("Lumen: Airplay device name: \(airplayOutput.portName)")
    return true
  }
}
