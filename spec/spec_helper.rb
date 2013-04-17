
$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), "../lib"))

require 'saml-sp'

require 'rspec'
require 'pp'
require 'fakeweb'

RSpec.configure do |config|
  # == Mock Framework
  #
  # RSpec uses it's own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
end


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt

