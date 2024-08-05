require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name                = package['name']
  s.version             = package['version']
  s.summary             = 'react-native-yz-vlcplayer'
  s.homepage            = 'https://github.com/delia-m/react-native-yz-vlcplayer'
  s.license             = package['license']
  s.author              = 'https://github.com/delia-m/react-native-yz-vlcplayer/graphs/contributors'
  s.source              = { :git => 'https://github.com/delia-m/react-native-yz-vlcplayer.git', :tag => '#{s.version}' }
  s.requires_arc        = true

  s.platform            = :ios, '9.0'

  s.preserve_paths      = 'ios/**/*'
  s.source_files        = 'ios/**/*.{h,m}'
  # s.libraries           = 'bz2', 'iconv'
  # s.framework           = 'AudioToolbox','AVFoundation', 'CFNetwork', 'CoreFoundation', 'CoreGraphics', 'CoreMedia', 'CoreText', 'CoreVideo', 'Foundation', 'OpenGLES', 'QuartzCore', 'Security', 'VideoToolbox', 'UIKit'

  s.static_framework = true
  
  s.dependency          'React'
  s.dependency          'MobileVLCKit'

end
