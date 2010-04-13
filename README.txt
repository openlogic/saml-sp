saml-sp
    by OpenLogic
    http://openlogic.com

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

#### Artifact Resolution Service
        
For artifact resolution to take place you need to configure an
artifact resolution service for the artifacts source.  This is done by
adding block similar to the following to your saml-sp config file.

    artifact_resolution_service {
      source_id   'opaque-id-of-the-idp'
      uri         'https://samlar.idp.example/resolve-artifact'
      issuer      'http://idp.example/'
      http_basic_auth {
        realm    'the-idp-realm'
        user_id  'my-user-id'
        password 'my-password'
      }
    }

The 'http_basic_auth' section is optional and only needed if the IdP
uses HTTP basic authentication.  

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

(The MIT License)

Copyright (c) 2010 OpenLogic

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
