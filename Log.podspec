Pod::Spec.new do |spec|
  spec.name         = 'Log'
  spec.platform 	= :ios, '10.0'
  spec.version      = '0.0.1'
  spec.homepage     = 'https://github.com/yeungkaho/SwiftLog'
  spec.authors      = { 'Kaho Yeung' => 'ykh.dev@gmail.com' }
  spec.summary      = 'A lightweight Swift logging utility'
  spec.source       = { :git => 'git@github.com:yeungkaho/SwiftLog.git', :tag => '0.0.1'}

  spec.requires_arc = true

  spec.source_files = 'Sources/*.swift'
  spec.dependency 'CollectionKit'
  
  spec.library       = 'z'

end
