set -oe pipefail

echo 'Testing ENV for COCOAPODS_TRUNK_TOKEN'
pod trunk me

sdk_version=$1
plugin_patch=$2

ruby scripts/prepare.rb $sdk_version $plugin_patch

# Pod lint
pod spec lint deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod spec lint deployment/LumenMeshDeliveryAVPlayerPlugin.podspec --verbose

# Pod push
pod trunk push deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod trunk push deployment/LumenMeshDeliveryAVPlayerPlugin.podspec --verbose