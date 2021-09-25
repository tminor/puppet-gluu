require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gluu_configuration',
  docs: <<~DOC,
    Basic configuration for Gluu Server.
  DOC
  features: ['canonicalize'],
  transport_info: {
    type: 'ldap',
  },
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether an organization configuration should be present or absent.',
      default: 'present'
    },
    ou: {
      type: 'String',
      default: 'configuration',
      behavior: :namevar,
      desc: 'TODO'
    },
    passport_enabled: {
      type: 'Boolean',
      default: true,
      alias: 'gluupassportenabled',
      desc: 'TODO'
    },
    saml_enabled: {
      type: 'Boolean',
      default: true,
      alias: 'gluusamlenabled',
      desc: 'TODO'
    },
    api_config: {
      type: <<~TYPE,
        Struct[
          password  => String[1],
          host_name => String[1],
          port      => Integer,
        ]
      TYPE
      behavior: :init_only,
      sensitive: true,
    },
    ldap_config: {
      type: <<~TYPE,
        Struct[
          password  => String[1],
          host_name => String[1],
          port      => Integer,
          username  => String[1],
        ]
      TYPE
      behavior: :init_only,
      sensitive: true,
      type_aliases: {
        password: 'Password'
      }
    },
    ssh_config: {
      type: <<~TYPE,
        Optional[Struct[
          password  => String[1],
          host_name => String[1],
          port      => Integer,
          username  => String[1],
        ]]
      TYPE
      behavior: :init_only,
      sensitive: true
    }
  },
)
