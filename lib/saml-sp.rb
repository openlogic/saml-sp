require 'logger'

module SamlSp

  # :stopdoc:
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
  VERSION = ::File.read(PATH + 'VERSION').strip
  # :startdoc:

  # Returns the version string for the library.
  #
  def self.version
    VERSION
  end

  # Returns the library path for the module. If any arguments are given,
  # they will be joined to the end of the libray path using
  # <tt>File.join</tt>.
  #
  def self.libpath( *args )
    args.empty? ? LIBPATH : ::File.join(LIBPATH, args.flatten)
  end

  # Returns the lpath for the module. If any arguments are given,
  # they will be joined to the end of the path using
  # <tt>File.join</tt>.
  #
  def self.path( *args )
    args.empty? ? PATH : ::File.join(PATH, args.flatten)
  end

  # Logger that does nothing
  BITBUCKET_LOGGER =  Logger.new(nil)
  class << BITBUCKET_LOGGER
    def add(*args)
    end
  end

  # The logger saml-sp should use
  def self.logger
    @@logger ||= BITBUCKET_LOGGER
  end

  # Set the logger for saml-sp
  def self.logger=(a_logger)
    @@logger = a_logger
  end
  
  module Logging
    def logger
      SamlSp.logger
    end
    
    def self.included(base)
      base.extend(self)
    end
  end

  autoload :Config,    'saml_sp/config'
end  # module SamlSp

require 'rubygems'

autoload :Saml2, 'saml2'

