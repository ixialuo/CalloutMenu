
Pod::Spec.new do |s|
  s.name             = "CalloutMenu"
  s.version          = "1.0.2"
  s.summary          = "menu for ios"
  s.homepage         = "https://github.com/codansYC/CalloutMenu"
  #s.license          = "MIT"
  s.author           = { "codansYC" => "yuan_chao000@sina.com" }
  s.source           = { :git => "https://github.com/codansYC/CalloutMenu.git", :tag => s.version.to_s }

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'CalloutMenu/CalloutMenu/YCCalloutMenuView.swift'
end