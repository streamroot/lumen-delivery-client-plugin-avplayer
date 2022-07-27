# SDK related
MESH_SDK_POD_NAME = 'LumenMeshSDK'
ORCHESTRATOR_SDK_POD_NAME = 'LumenOrchestratorSDK'
IOS_TARGET_VERSION = '10.0'
TVOS_TARGET_VERSION = '10.0'
SDK_VERSION = "22.06"

# Plugin related
PLUGIN_VERSION = SDK_VERSION
SWIFT_VERSION = '5.5'

MESH_AVPLUGIN_POD_NAME = 'LumenMeshAVPlayerPlugin'
MESH_SUMMARY = 'Lumen Mesh SDK AVPlayer plugin, a new way to deliver large-scale OTT video'

ORCHESTRATOR_AVPLUGIN_POD_NAME = 'LumenCDNLoadBalancerAVPlayerPlugin'
ORCHESTRATOR_SUMMARY = 'Lumen CDN Load Balancer SDK AVPlayer plugin.'

HOMEPAGE = 'https://www.streamroot.io/'
AUTHORS = { 'Support' => 'support-team@streamroot.io' }
LICENSE = {
    :type => 'Copyright',
    :text => 'Copyright 2022 Streamroot. See the terms of service at https://www.streamroot.io/'
}

# DRY utils
def default_spec_setup(s)
    s.version           = VERSION
    s.swift_version     = SWIFT_VERSION
    s.homepage          = HOMEPAGE
    s.author            = AUTHORS
    s.license           = LICENSE
    s.platform          = :ios
    s.source            = { :git => 'https://github.com/streamroot/lumen-delivery-client-plugin-avplayer.git', :tag => "#{VERSION}"}
    s.source_files      = 'AVPlugin/AVPlugin/*.swift'
    s.ios.deployment_target = IOS_TARGET_VERSION
    s.tvos.deployment_target = TVOS_TARGET_VERSION
    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
    }
    s.user_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
    }
end