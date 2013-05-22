begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = 'openlogic-saml-sp'
    gemspec.summary = 'SAML 2.0 SSO Sevice Provider Library'
    gemspec.email = ['gbettridge@openlogic.com', 'todd.thomas@openlogic.com']
    gemspec.authors = ["OpenLogic", "Peter Williams", "Glen Aultman-Bettridge", "Todd Thomas"]
    gemspec.homepage = 'https://github.com/openlogic/saml-sp'
    gemspec.add_dependency 'nokogiri'
    gemspec.add_dependency 'signed_xml', '~> 1.0'
    gemspec.add_dependency 'openlogic-resourceful'
    gemspec.add_dependency 'uuidtools'
    gemspec.add_development_dependency 'rspec', '~> 2.12'
    gemspec.add_development_dependency 'fakeweb'
    gemspec.files = FileList["[A-Z]*", "{bin,generators,lib,test,spec,rails}/**/*"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new(:spec)

task :default => :spec
# EOF


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

