SamlSp::Config.load_file(File.join(RAILS_ROOT, "config/saml_sp.conf"))

env_specific_config_file = File.join(RAILS_ROOT, "config/#{Rails.env}/saml_sp.conf")

SamlSp::Config.load_file(env_specific_config_file) if File.exists? env_specific_config_file
