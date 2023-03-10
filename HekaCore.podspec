Pod::Spec.new do |s|
    s.name             = 'HekaCore'
    s.version          = '0.0.5'
    s.summary          = 'Integrate fitness data sources into your app.'
    s.homepage         = 'https://www.hekahealth.co'
    s.license          = { :type => 'GNU AGPL', :file => 'LICENSE' }
    s.author           = { 'Heka' => 'contact@hekahealth.co' }
    s.source           = { :git => 'https://github.com/HekaHealth/HekaCore.git', :tag => s.version.to_s }
    s.ios.deployment_target = '11.0'
    s.swift_version = '5.0'
    s.source_files = 'Sources/HekaCore/**/*.{swift, plist}'
    s.dependency 'Alamofire', '~> 5.6.1'
    s.dependency 'PromiseKit', '~> 6.8.0'
    s.dependency 'Logging', '~> 1.4.0'
  end