saml-sp
    by OpenLogic
    http://openlogic.com

## DESCRIPTION:

Support for being a SAML 2.0 service provider.

## SYNOPSIS:

This library provides parsing of SAML 2.0 artifacts.  For example.
    
    artifact = Saml2::Type4Artifact.new_from_string(params['SAMLart'])  # => #<Saml2::Type4Artifact ...>
    artifact.source_id                                                  # => 'a314Xc8KaSd4fEJAd8R'
    artifact.type_code                                                  # => 4
    
    

## REQUIREMENTS:

* Nokogiri

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
