require 'puppet/resource_api/data_type_handling'


module PuppetX::Gluu::Mapper
  class Base
    include Enumerable

    def self.[](key)
      return if key.nil?

      instance_variable_get("@#{key}")
    end

    def [](key)
      instance_variable_get("@#{key}")
    end

    def initialize(context)
      context.type.attributes.each { |attr, schema| map_entry! attr, schema }
    end

    def each
      instance_variables
    end

    def map_entry!(name, schema)
      return if [:ensure].member? name

      schema[:name] = name
      schema[:type] = Puppet::ResourceApi::DataTypeHandling.parse_puppet_type(name, schema[:type])

      instance_variable_set("@#{name}", Param.new(schema, self))
    end

    class Param
      attr_reader :canonical, :schema
      attr_writer :pointer

      def initialize(schema, mapper, canonical = true)
        @canonical = canonical

        if schema[:alias] && canonical
          @pointer = mapper.instance_variable_set("@#{schema[:alias]}", self.class.new(schema, mapper, false))
          @pointer.pointer = self
        end

        @schema = schema
      end
    end
  end
end
