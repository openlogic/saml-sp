
begin
  require 'bones'
rescue LoadError
  abort '### Please install the "bones" gem ###'
end

ensure_in_path 'lib'
require 'saml-sp'

task :default => 'test:run'
task 'gem:release' => 'test:run'

Bones {
  name     'saml-sp'
  authors  'Peter Williams'
  email    'pezra@barleyenough.org'
  url      'http://barelyenough.org'
  version  SamlSp::VERSION
}

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new

# EOF
