Gem::Specification.new do |s|
  s.name = 'weblet'
  s.version = '0.2.2'
  s.summary = 'Intended for retrieving HTML templates from a ' +
      'convenient to use Hash-like object.'
  s.authors = ['James Robertson']
  s.files = Dir['lib/weblet.rb']
  s.add_runtime_dependency('rexle', '~> 1.5', '>=1.5.10')
  s.signing_key = '../privatekeys/weblet.pem'
  s.cert_chain  = ['gem-public_cert.pem']
  s.license = 'MIT'
  s.email = 'digital.robertson@gmail.com'
  s.homepage = 'https://github.com/jrobertson/weblet'
end
