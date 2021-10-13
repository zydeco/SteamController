Pod::Spec.new do |s|
  s.name             = 'SteamController'
  s.version          = '1.3'
  s.summary          = 'Support Steam Controller in BLE mode.'
  s.description      = <<-DESC
Drop-in support for Steam Controllers in iOS/tvOS games.
                       DESC

  s.homepage         = 'https://github.com/zydeco/SteamController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jesús A. Álvarez' => 'zydeco@namedfork.net' }
  s.source           = { :git => 'https://github.com/zydeco/SteamController.git', :tag => 'v'+s.version.to_s }
  s.social_media_url = 'https://twitter.com/maczydeco'

  s.ios.deployment_target = '10.0'
  s.tvos.deployment_target = '10.0'

  s.frameworks = 'GameController', 'CoreBluetooth'

  s.default_subspec = 'default'
  s.subspec 'default' do |ss|
    ss.source_files = 'Sources/SteamController/*.{h,m}'
    ss.public_header_files = 'Sources/SteamController/include/SteamController/*.h'
  end

  s.subspec 'no-private-api' do |ss|
    ss.compiler_flags = '-DSTEAMCONTROLLER_NO_PRIVATE_API'
    ss.source_files = 'Sources/SteamController/*.{h,m}'
    ss.public_header_files = 'Sources/SteamController/include/SteamController/*.h'
  end
end
