STDERR.puts "in init.rb"

["config/saml_sp.conf", "config/#{Rails.env}/saml_sp.conf"].each do |f|
  
  config_file = File.expand(f, Rails.root)
  if File.exists? config_file
    SamlSp::Config.load_file config_file
  else
    Rails.logger.debug "Skipping config file '#{config_file}' because it does not exist"
  end
end

SamlSp.logger = Rails.logger
