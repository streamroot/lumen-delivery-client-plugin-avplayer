# Import config
require '../config.rb'

Pod::Spec.new do |s|
    default_spec_setup(s)
    s.name              = MESH_AVPLUGIN_POD_NAME
    s.summary           = MESH_SUMMARY
    s.dependency MESH_SDK_POD_NAME, "~> #{SDK_VERSION}.0"

    # Code is preprocessor forked
    s.pod_target_xcconfig['OTHER_SWIFT_FLAGS[*]'] = '-DMESH'
end