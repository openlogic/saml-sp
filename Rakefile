
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'saml-rp'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name  'saml-rp'
  authors  'Peter Williams'
  email    'pezra@barleyenough.org'
  url      'http://barelyenough.org'
  version  SamlRp::VERSION
}

# EOF
