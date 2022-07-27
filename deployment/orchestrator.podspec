# Import config
require '../config.rb'

Pod::Spec.new do |s|
    default_spec_setup(s)
    s.name              = ORCHESTRATOR_AVPLUGIN_POD_NAME
    s.summary           = ORCHESTRATOR_SUMMARY
    s.dependency ORCHESTRATOR_SDK_POD_NAME, "~> #{SDK_VERSION}.0"
end