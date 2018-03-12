Gem::Specification.new do |s|
	s.name        = "kotsms"
	s.version     = "0.2.0"
	s.date        = "2018-03-13"
	s.summary     = "API wrapper for SMS King (www.kotsms.com.tw)"
	s.description = "This gem wraps the web API of SMS King (www.kotsms.com.tw) for Rubyists."
	s.authors     = ["CrBoy"]
	s.email       = "crboy@crboy.net"
	s.files       = ["lib/kotsms.rb"]
	s.homepage    = "https://github.com/CrBoy/kotsms-gem"
	s.license       = "MIT"
	s.add_runtime_dependency "iconv", "~> 1.0"
end
