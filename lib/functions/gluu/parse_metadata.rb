Puppet::Functions.create_function(:'gluu::parse_metadata') do
  require 'ruby-saml'

  dispatch :parse do
    param 'String', :file
  end

  def parse(file)
    parser = OneLogin::RubySaml::IdpMetadataParser.new
    parser.parse(File.open(file))
  end
end
