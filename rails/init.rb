SamlSp.logger = Rails.logger

["config/saml_sp.conf", "config/#{Rails.env}/saml_sp.conf"].each do |f|
  config_file = File.join(Rails.root, f)
  if File.exists? config_file
    SamlSp::Config.load_file config_file
  else
    SamlSp.logger.debug "saml-sp: Skipping config file '#{config_file}' because it does not exist"
  end
end

