Gem::Specification.new do |s|
  s.name        = 'octoputs'
  s.version     = '0.0.0'
  s.date        = '2019-06-07'
  s.summary     = "Octoputs"
  s.description = "A web server that stdouts everything it gets"
  s.authors     = ["Jesus Burgos Macia"]
  s.files       = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  s.extensions  = ["ext/puma_http11/extconf.rb"]

  s.require_paths = ["lib"]

  s.license       = 'MIT'
end
