
module SamlSp

  # :stopdoc:
  VERSION = '1.0.0'
  LIBPATH = ::File.expand_path(::File.dirname(__FILE__)) + ::File::SEPARATOR
  PATH = ::File.dirname(LIBPATH) + ::File::SEPARATOR
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

  autoload :Config,    'saml_sp/config'
end  # module SamlSp

require 'rubygems'

module Saml2
  autoload :Type4Artifact,             'saml2/type4_artifact'
  autoload :Assertion,                 'saml2/assertion'
  autoload :ArtifactResolver,          'saml2/artifact_resolver'
  autoload :BasicAuthArtifactResolver, 'saml2/basic_auth_artifact_resolver'
end

