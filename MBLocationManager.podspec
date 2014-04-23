Pod::Spec.new do |s|
  s.name         = "MBLocationManager"
  s.version      = "0.0.1"
  s.platform     = :ios, '6.0'
  s.ios.deployment_target = '6.0'
  s.summary      = "MBLocationManager is designed for use single instance of location service within app."
  s.description  = <<-DESC
MBLocationManager is designed for use single instance of location service within app.

Requires

* CoreLocation.framework

DESC

  s.homepage     = "https://github.com/key/MBLocationManager"
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { "Mitsukuni Sato" => "mitsukuni.sato@gmail.com" }
  s.source       = { :git => 'https://github.com/key/MBLocationManager.git', :tag => '0.0.1' }
  s.source_files = 'MBLocationManager/Classes/**/*.{h,m}'
  s.frameworks   = 'CoreLocation'
  s.requires_arc = true

end
