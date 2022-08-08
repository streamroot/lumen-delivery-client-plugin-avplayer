# Import config
require '../config.rb'

Pod::Spec.new do |s|
    default_spec_setup(s)
    s.name              = ORCHESTRATOR_AVPLUGIN_POD_NAME
    s.summary           = ORCHESTRATOR_SUMMARY
    s.dependency ORCHESTRATOR_SDK_POD_NAME, "~> #{SDK_VERSION}.0"

    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64'
    }
end