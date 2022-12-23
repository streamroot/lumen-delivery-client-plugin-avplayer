# Import config
require './config.rb'

puts "SDK version resolved to #{SDK_VERSION}"

use_frameworks!

workspace 'avplugin.xcworkspace'

abstract_target 'Plugin' do
  project 'AVPlugin/AVPlugin'

  abstract_target 'Mesh' do
    pod MESH_SDK_POD_NAME, SDK_VERSION

    target 'LumenAVMeshPlugin' do
      platform :ios, IOS_TARGET_VERSION
    end

    target 'LumenAVMeshPluginTV' do
      platform :tvos, TVOS_TARGET_VERSION
    end
  end

  abstract_target 'Orchestrator' do
    pod ORCHESTRATOR_SDK_POD_NAME, SDK_VERSION

    target 'LumenAVOrchestratorPlugin' do
      platform :ios, IOS_TARGET_VERSION
    end

    target 'LumenAVOrchestratorPluginTV' do
      platform :tvos, TVOS_TARGET_VERSION
    end
  end
  
  abstract_target 'PluginTests' do
    target 'LumenAVMeshPluginTests' do
      platform :ios, IOS_TARGET_VERSION
    end
    target 'LumenAVMeshPluginTVTests' do
      platform :tvos, TVOS_TARGET_VERSION
    end
    target 'LumenAVOrchestratorPluginTests' do
      platform :ios, IOS_TARGET_VERSION
    end
    target 'LumenAVOrchestratorPluginTVTests' do
      platform :tvos, TVOS_TARGET_VERSION
    end
  end
end

abstract_target 'DemoApp' do
  project 'AVPlayerDemo/AVPlayerDemo'

  abstract_target 'Mesh' do
    pod MESH_SDK_POD_NAME, SDK_VERSION

    target 'AVPlayerMeshDemo' do
      platform :ios, IOS_TARGET_VERSION
    end
  
    target 'AVPlayerMeshDemoTV' do
      platform :tvos, TVOS_TARGET_VERSION
    end
  end

  abstract_target 'Orchestrator' do
    pod ORCHESTRATOR_SDK_POD_NAME, SDK_VERSION

    target 'AVPlayerOrchestratorDemo' do
      platform :ios, IOS_TARGET_VERSION
    end
  
    target 'AVPlayerOrchestratorDemoTV' do
      platform :tvos, TVOS_TARGET_VERSION
    end
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_TARGET_VERSION
      config.build_settings['TVOS_DEPLOYMENT_TARGET'] = TVOS_TARGET_VERSION
      config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
      config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
      config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
      config.build_settings['ENABLE_BITCODE'] = "NO"
      config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
    end
  end
end
