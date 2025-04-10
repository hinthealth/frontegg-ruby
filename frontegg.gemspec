Gem::Specification.new do |s|
  s.name                  = 'frontegg'
  s.version               = '0.1.0'
  s.date                  = '2023-07-26'
  s.summary               = 'Ruby library for the Frontegg API'
  s.authors               = ['Hint']
  s.files                 = Dir['lib/**/*.rb']
  s.license               = 'MIT'
  s.required_ruby_version = '>= 2.7'

  s.add_dependency 'faraday', '~> 2.12'
  s.add_dependency 'jwt', '~> 2.7.1', '>= 2'
end
