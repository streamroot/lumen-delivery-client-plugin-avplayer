# Import config
require '../config.rb'

Pod::Spec.new do |s|
    default_spec_setup(s)
    s.name              = MESH_AVPLUGIN_POD_NAME
    s.summary           = MESH_SUMMARY
    s.dependency MESH_SDK_POD_NAME, "~> #{SDK_VERSION}"

    s.pod_target_xcconfig = {
        'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
        'EXCLUDED_ARCHS[sdk=appletvsimulator*]' => 'arm64',
        'OTHER_SWIFT_FLAGS' => '-DMESH' # Code is preprocessor forked
    }
end