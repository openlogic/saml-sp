SamlSp.logger = Rails.logger

config_file = File.join(Rails.root, 'config/saml_sp.conf')
SamlSp::Config.load_file config_file if File.exists? config_file



# Licensed under MIT license.  See README.txt for details.
