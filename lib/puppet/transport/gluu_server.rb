class Puppet::Transport::GluuServer
  attr_reader :connection

  def initialize(_context, connection_info)
    @connection = connect(connection_info)
  end

  def verify(context)
  end

  def facts(context)
    {}
  end

  def close(context)
  end

  def connect(conn_info)
    transport = get_transport_class(conn_info[:type])
    transport.new(conn_info)
  end

  private

  def get_transport_class(type)
    ns = 'PuppetX::Gluu::Connection'
    Kernel.const_get("#{ns}::#{type.capitalize}")
  end
end
