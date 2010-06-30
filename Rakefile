begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'saml-sp'
    gemspec.summary = 'SAML 2.0 SSO Sevice Provider Library'
    gemspec.email = 'pezra@barelyenough.org'
    gemspec.authors = ["OpenLogic", "Peter Williams"]
    gemspec.add_dependency 'nokogiri'
    gemspec.add_dependency 'openlogic-resourceful'
    gemspec.add_dependency 'uuidtools'
    gemspec.add_development_dependency 'rspec'
    gemspec.files = FileList["[A-Z]*", "{bin,generators,lib,test,spec,rails}/**/*"]
  end
#  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new

task 'test:run' => :spec 
# EOF



# Licensed under MIT license.  See README.txt for details.
