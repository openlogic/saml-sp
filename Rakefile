
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
  name      'saml-sp'
  authors   'Peter Williams'
  email     'pezra@barleyenough.org'
  url       'http://github.com/pezra/saml-sp'
  version   SamlSp::VERSION
  summary   'SAML 2.0 SSO Sevice Provider Library'
  depend_on 'nokogiri'
  depend_on 'resourceful'
  depend_on 'uuidtools'
  depend_on 'fakeweb', :dev => true
}

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new

task 'test:run' => :spec 
# EOF
