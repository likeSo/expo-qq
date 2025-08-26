require 'json'

package = JSON.parse(File.read(File.join(__dir__, '..', 'package.json')))

Pod::Spec.new do |s|
  s.name           = 'ExpoQQ'
  s.version        = package['version']
  s.summary        = package['description']
  s.description    = package['description']
  s.license        = package['license']
  s.author         = package['author']
  s.homepage       = package['homepage']
  s.platforms      = {
    :ios => '15.1',
    :tvos => '15.1'
  }
  s.swift_version  = '5.4'
  s.source         = { git: 'https://github.com/likeSo/expo-qq' }
  s.static_framework = true

  s.dependency 'ExpoModulesCore'
  
#  s.vendored_frameworks = 'Frameworks/*.framework'
#  s.frameworks = 'Security', 'SystemConfiguration', 'CoreGraphics', 'CoreTelephony'
#  s.libraries = 'iconv', 'sqlite3', 'stdc++', 'z'
#  
#  s.pod_target_xcconfig = {
#    'HEADER_SEARCH_PATHS' => '"$(inherited)" "${PODS_TARGET_SRCROOT}/Frameworks/TencentOpenAPI.framework/Headers"',
#    'FRAMEWORK_SEARCH_PATHS' => '"${PODS_TARGET_SRCROOT}/Frameworks"',
#    'DEFINES_MODULE' => 'YES',
#    'CLANG_ENABLE_MODULES' => 'YES',
#  }

  s.vendored_frameworks = 'Frameworks/*.xcframework'
  s.frameworks = 'Security', 'SystemConfiguration', 'CoreGraphics', 'CoreTelephony'
  s.libraries = 'iconv', 'sqlite3', 'stdc++', 'z'

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'CLANG_ENABLE_MODULES' => 'YES',
  }
  s.source_files = "Classes/**/*.{h,m,mm,swift,hpp,cpp}"
  
  
end

#    'HEADER_SEARCH_PATHS' => '"$(inherited)" "${PODS_TARGET_SRCROOT}/Framework/TencentOpenAPI.xcframework/ios-arm64_armv7/TencentOpenAPI.framework/Headers" "${PODS_TARGET_SRCROOT}/Framework/TencentOpenAPI.xcframework/ios-arm64_i386_x86_64-simulator/TencentOpenAPI.framework/Headers"',
