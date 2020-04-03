Pod::Spec.new do |spec|
  spec.name         = 'Log'
  spec.platform 	= :ios, '10.0'
  spec.version      = '0.0.1'
  spec.homepage     = 'https://github.com/XXXXX'
  spec.authors      = { 'Kaho Yeung' => 'yeungkaho@gmail.com' }
  spec.summary      = 'DragonPlus SDK for iOS'
  spec.source       = { :git => 'git@github.com:TODO.git', :tag => '0.0.1'}

  spec.requires_arc = true

  spec.source_files = 'Sources/*.swift'
  spec.dependency 'CollectionKit'
  
  spec.library       = 'z'

end
