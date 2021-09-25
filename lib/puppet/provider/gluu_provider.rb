require 'loader'
require 'forwardable'
require 'puppet/resource_api/simple_provider'

# Inherited by "real" providers. This class includes convenience
# methods for connecting via Puppet::Transport::GluuServer.
class Puppet::Provider::GluuProvider < Puppet::ResourceApi::SimpleProvider
  include Loader

  extend Forwardable

  using PuppetX::Gluu::CoreExtensions

  TransportConfigRegistry = proc { |configs| class_attr_accessor(*configs) }

  define_method 'register_transport_configs' do |configs|
    TransportConfigRegistry[configs]
  end

  def get(context, **query)
    connect(context)
    res = @transport.connection.search(**query)
  end

  def connect(context)
    transport_info = context.type.definition[:transport_info]
    transport_type = transport_info[:type]
    connection_info = send("#{transport_type}_config").merge(transport_info)
    @transport = Puppet::ResourceApi::Transport.connect('gluu_server', connection_info)
    @mapper = get_mapper(context)
  end

  def get_mapper(context)
    klass = self.class.to_s.split('::').last
    ns = 'PuppetX::Gluu::Mapper'
    Kernel.const_get("#{ns}::#{klass}").new(context)
  end

  # Only used by the gluu_configuration resource currently.
  class SingletonProvider < Puppet::Provider::GluuProvider
    @instantiated = false

    class_attr_accessor :instantiated

    def canonicalize(context, resources)
      raise SingletonResourceException.new(context.type.name, resources.first[:ou]) if instantiated

      self.instantiated = true
    end

    class SingletonResourceException < StandardError
      def initialize(resource, name)
        super(
          "Exception creating #{resource.capitalize}['#{name}']: #{resource} can only be created once"
        )
      end
    end
  end
end
