Pod::Spec.new do |s|
	s.name             = 'SwiftDocumentScanner'
	s.version          = '0.1.0'
	s.summary          = 'Documentscanner app like Notes.'
	s.homepage         = 'https://github.com/jonasbeckers/SwiftDocumentScanner'
	s.license          = { :type => 'MIT', :file => 'LICENSE' }
	s.author           = { 'jonasbeckers' => 'jonas.beckers1996@gmail.com' }
	s.source           = { :git => 'https://github.com/jonasbeckers/SwiftDocumentScanner.git', :tag => s.version.to_s }
	s.ios.deployment_target = '9.0'
	s.source_files = 'SwiftDocumentScanner/Classes/**/*.swift'
	s.dependency 'CropView', '0.1.3'
end
