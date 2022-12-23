require 'json'

begin
    MUTABLE_CONTENT = JSON.parse(File.read('../config.json'))
rescue => e
    MUTABLE_CONTENT = JSON.parse(File.read('./config.json'))
end

# SDK related
MESH_SDK_POD_NAME = 'LumenMeshSDK'
ORCHESTRATOR_SDK_POD_NAME = 'LumenOrchestratorSDK'
IOS_TARGET_VERSION = '11.0'
TVOS_TARGET_VERSION = '11.0'
SDK_VERSION = MUTABLE_CONTENT['SDK_VERSION']

# Plugin related
PLUGIN_PATCH = MUTABLE_CONTENT['PLUGIN_PATCH']
PLUGIN_VERSION = "#{SDK_VERSION}.#{PLUGIN_PATCH}"

SWIFT_VERSION = '5.5'

MESH_AVPLUGIN_POD_NAME = 'LumenMeshDeliveryAVPlayerPlugin'
MESH_SUMMARY = 'Lumen Mesh Delivery SDK AVPlayer plugin, a new way to deliver large-scale OTT video'

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
    s.version           = PLUGIN_VERSION
    s.swift_version     = SWIFT_VERSION
    s.homepage          = HOMEPAGE
    s.author            = AUTHORS
    s.license           = LICENSE
    s.platform          = :ios
    s.source            = { :git => 'https://github.com/streamroot/lumen-delivery-client-plugin-avplayer.git', :tag => "#{PLUGIN_VERSION}"}
    s.source_files      = 'AVPlugin/AVPlugin/*.swift'
    s.ios.deployment_target = IOS_TARGET_VERSION
    s.tvos.deployment_target = TVOS_TARGET_VERSION
    s.user_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
    }
end
