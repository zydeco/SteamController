Pod::Spec.new do |s|
  s.name             = 'SteamController'
  s.version          = '1.1'
  s.summary          = 'Support Steam Controller in BLE mode.'
  s.description      = <<-DESC
Drop-in support for Steam Controllers in iOS/tvOS games.
                       DESC

  s.homepage         = 'https://github.com/zydeco/SteamController'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Jesús A. Álvarez' => 'zydeco@namedfork.net' }
  s.source           = { :git => 'https://github.com/zydeco/SteamController.git', :tag => 'v'+s.version.to_s }
  s.social_media_url = 'https://twitter.com/maczydeco'

  s.ios.deployment_target = '9.0'
  s.tvos.deployment_target = '9.0'

  s.frameworks = 'GameController', 'CoreBluetooth'
  
  s.default_subspec = 'default'
  s.subspec 'default' do |ss|
    ss.source_files = 'SteamController/*'
    ss.public_header_files = 'SteamController/*.h'
  end
  
  s.subspec 'no-private-api' do |ss|
    ss.compiler_flags = '-DSTEAMCONTROLLER_NO_PRIVATE_API'
    ss.source_files = 'SteamController/*'
    ss.public_header_files = 'SteamController/*.h'
  end
end
