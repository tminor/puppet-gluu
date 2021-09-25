module PuppetX::Gluu::Helpers::Xml
  require 'nori'
  require 'gyoku'

  # This method attempts to cast an XML value to its equivalent Puppet
  # type.
  #
  # @param value [String] a value returned by `Nori#parse`.
  # @param type [Puppet::Pop::Types::PAnytype] a Puppet data type.
  # @return [String, Hash, Array, Integer, Boolean]
  #   `value` cast as a Ruby type equivalent to its Puppet counterpart.
  def xml_to_puppet_value(value, type)
    return value unless type

    puppet_type = type.value_type
    case puppet_type
    when Puppet::Pops::Types::PTupleType
      value.split(',')
    when Puppet::Pops::Types::PStringType
      value
    when Puppet::Pops::Types::PBooleanType
      value == 'true'
    when Puppet::Pops::Types::PIntegerType
      value.to_i
    else
      value
    end
  end

  # This method takes XML as a string representation or as a hash
  # returned by `Nori.parse`.
  #
  # @param xml [Hash] a hash representation of XML.
  #   returned by `Nori.parse`.
  # @param type [Puppet::Pop::Types::PStructType] a Puppet struct
  #   schema that should match the provided XML string/hash.
  # @param key_aliases [Hash<String, String>] a hash mapping XML keys
  #   to different representations (e.g. camel case => snake case).
  # @param direction [Symbol] determines how to transform keys and
  #   values.
  # @return [Hash] a hash that matches a Puppet type schema or XML
  #   schema.
  def xml_puppet_struct_transform(xml, type, key_aliases, direction)
    transformed = {}
    if direction == :to_puppet
      xml.each do |k, v|
        local_type = type.type.elements.find do |e|
          e.key_type.size_type_or_value == key_aliases[k].to_s
        end
        value = xml_to_puppet_value(v, local_type)
        transformed[key_aliases[k]] = value if key_aliases[k]
      end
    elsif direction == :to_xml
      xml.each do |k, v|
        key = key_aliases.key(k)
        transformed[key] = v.is_a?(Array) ? v.join(',') : v
      end
    end
    transformed
  end
end
