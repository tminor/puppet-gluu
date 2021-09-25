module PuppetX::Gluu::Helpers::Types
  def parse_type_schema(type)
    type_parser = Puppet::Pops::Types::TypeParser.singleton
    type_parser.parse(type)
  end
end
