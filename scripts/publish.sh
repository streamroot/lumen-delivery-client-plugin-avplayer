set -o pipefail

ruby scripts/prepare.rb $1 $2

# Pod lint
pod spec lint deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod spec lint deployment/LumenMeshAVPlayerPlugin.podspec --verbose

# Pod push
pod trunk push deployment/LumenCDNLoadBalancerAVPlayerPlugin.podspec --verbose
pod trunk push deployment/LumenMeshAVPlayerPlugin.podspec --verbose