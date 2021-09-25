require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gluu_api',
  docs: <<~DOC,
  DOC
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether an attribute should be present or absent.',
      default: 'present'
    },
    name: {
      behaviour: :namevar,
      type: 'String',
      default: 'default',
      desc: 'TODO'
    },
    api_key_pass: {
      type: 'String[1]',
      desc: 'TODO'
    },
    ldap_admin_pass: {
      type: 'String[1]',
      desc: 'TODO'
    },
    oxtrust_admin_pass: {
      type: 'String[1]',
      desc: 'TODO'
    },
  },
)
