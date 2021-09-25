module PuppetX::Gluu
  class BaseConnection
    using PuppetX::Gluu::CoreExtensions

    class_attr_accessor :connections

    @connections = {}
  end
end
