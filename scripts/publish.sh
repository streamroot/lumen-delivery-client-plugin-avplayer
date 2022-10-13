set -o pipefail

sdk_version=$1
plugin_patch=$2

ruby scripts/prepare.rb $sdk_version $plugin_patch

# Pod lint
pod spec lint deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod spec lint deployment/LumenMeshDeliveryAVPlayerPlugin.podspec --verbose

# Pod push
pod trunk push deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod trunk push deployment/LumenMeshDeliveryAVPlayerPlugin.podspec --verbose