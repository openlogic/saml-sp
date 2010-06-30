saml-sp
    by OpenLogic
    http://openlogic.com
    peter.williams@openlogic.com

## STATUS:

This library is un-stable and under active development.  Version
identifiers follow
[rational version ](http://docs.rubygems.org/read/chapter/7#page26).
The major version number does not indicate this library is stable or
complete (or even functional).

## DESCRIPTION:

Support for being a SAML 2.0 service provider in an HTTP artifact
binding SSO conversation.

## SYNOPSIS:

This library provides parsing of SAML 2.0 artifacts.  For example.
    
    artifact = Saml2::Type4Artifact.new_from_string(params['SAMLart'])  # => #<Saml2::Type4Artifact ...>
    artifact.source_id                                                  # => 'a314Xc8KaSd4fEJAd8R'
    artifact.type_code                                                  # => 4

Once you have an artifact you can resolve it into it's associated assertion:

    assertion = artifact.resolve     # => #<Saml2::Assertion>

With the assertion you can identify the user and retrieve attributes:

    assertion.subject_name_id        # => '1234'
    assertion['mail']                # => 'john.doe@idp.example'

### Configuration
        
If you are using Rails the SamlSp will automatically load
configuration info from `config/saml_sp.conf`.

For non-Rails apps the saml-sp configuration file can be place in the
application configuration directory and loaded using the following
code during application startup.

    SamlSp::Config.load_file(APP_ROOT + "/config/saml_sp.conf")

#### Logging

If you are using saml-sp in a rails app it will automatically log to
the Rails default logger.  For non-Rails apps you can specify a Logger
object to be used in the config file.

    logger MY_APP_LOGGER


#### Artifact Resolution Service
        
For artifact resolution to take place you need to configure an
artifact resolution service for the artifacts source.  This is done by
adding block similar to the following to your saml-sp config file.

    artifact_resolution_service {
      source_id         'opaque-id-of-the-idp'
      uri               'https://samlar.idp.example/resolve-artifact'
      identity_provider 'http://idp.example/'
      service_provider  'http://your-domain.example/'
      http_basic_auth {
        realm    'the-idp-realm'
        user_id  'my-user-id'
        password 'my-password'
      }
    }

The configuration details are:

 * source_id: 
   The id of the source that this resolution service can
   resolve.  This is a 20 octet binary string.
 
 * uri:
   The endpoint to which artifact resolve requests should be sent.
 
 * identity_provider:
   The URI identifying the identity provider that issues assertions 
   using the source id specified.
   
 * service_provider:
   The URI identifying the your software (the service provider) to 
   the identity provider.
   
 * http_basic_auth:
   (Optional) The credentials needed to authenticate with the IdP
   using HTTP basic authentication.  

#### Promiscuous Auth

If the IdP does not provide proper HTTP challenge responses you can
specify the HTTP auth in promiscuous mode. For example,

    http_basic_auth {
      promiscuous
      user_id  'my-user-id'
      password 'my-password'
    }

In promiscuous mode the credentials are sent with every request to
this resolutions service regardless of it's realm.


## REQUIREMENTS:

 * Nokogiri
 * Resourcful
 * uuidtools
 
## INSTALL:

 * sudo gem install saml-sp

## LICENSE:

Copyright (c) 2010 OpenLogic

Licensed under the MIT License.  See LICENSE.txt
