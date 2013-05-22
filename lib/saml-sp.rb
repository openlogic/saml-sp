require 'digest'
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

  CertificateStore = Class.new(Hash) do
    include Logging

    def load_certificates(glob)
      logger.info "loading certificates from #{glob}"
      Dir[glob].each do |file|
        begin
          next unless File.file?(file)
          logger.info "reading #{file}"
          cert = OpenSSL::X509::Certificate.new(File.read(file))
          fingerprint = Digest::SHA1.hexdigest(cert.to_der)
          self[fingerprint] = cert
          logger.info "loaded certificate #{cert.inspect} with fingerprint #{fingerprint}"
        rescue StandardError => e
          logger.warn "unable to read X.509 cert from #{file}: #{e.message}"
        end
      end
    end
  end.new

  autoload :Config,    'saml_sp/config'
end  # module SamlSp

require 'rubygems'

autoload :Saml2, 'saml2'


# Copyright (c) 2010 OpenLogic
#
# Licensed under MIT license.  See LICENSE.txt
