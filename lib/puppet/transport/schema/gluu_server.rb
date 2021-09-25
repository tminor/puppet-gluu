Puppet::ResourceApi.register_transport(
  name: 'gluu_server',
  desc: "Connects to Gluu Server",
  connection_info: {
    type: {
      type: 'Enum[api, ssh, ldap]',
      desc: 'How to connect to Gluu Server.',
    },
    host_name: {
      type: 'String',
      desc: 'The host to connect to.',
    },
    username: {
      type: 'Optional[String]',
      desc: 'The user to connect as.',
    },
    password: {
      type: 'Optional[String]',
      sensitive: true,
    },
    port: {
      type: 'Optional[Integer]',
      desc: 'The port to connect to.',
    },
  },
)
