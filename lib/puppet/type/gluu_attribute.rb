require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gluu_attribute',
  docs: <<~DOC,
  DOC
  transport_info: {
    type: 'api',
    endpoint: 'attributes',
  },
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether an attribute should be present or absent.',
      default: 'present'
    },
    name: {
      type: 'String[1]',
      desc: 'The name of the attribute.',
      behaviour: :namevar
    },
    dn: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    selected: {
      type: 'Optional[Boolean]',
      desc: 'TODO'
    },
    inum: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    type: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    lifetime: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    salt: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    description: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    display_name: {
      type: 'String',
      alias: 'displayName',
      desc: 'TODO'
    },
    data_type: {
      type: <<~TYPE,
        Enum[
          "STRING",
          "NUMERIC",
          "BOOLEAN",
          "BINARY",
          "CERTIFICATE",
          "DATE"
        ]
      TYPE
      alias: 'dataType',
      desc: 'TODO'
    },
    edit_type: {
      type: 'Tuple[Enum["ADMIN", "USER"], 1, 2]',
      default: ['ADMIN'],
      alias: 'editType',
      desc: 'TODO'
    },
    view_type: {
      type: 'Tuple[Enum["ADMIN", "USER"], 1, 2]',
      default: %w[ADMIN USER],
      alias: 'viewType',
      desc: 'TODO'
    },
    ox_scim_custom_attribute: {
      type: 'Optional[Boolean]',
      alias: 'oxSCIMCustomAttribute',
      desc: 'TODO'
    },
    ox_multi_valued_attribute: {
      type: 'Optional[Boolean]',
      alias: 'oxMultiValuedAttribute',
      desc: 'TODO'
    },
    custom: {
      type: 'Boolean',
      default: true,
      desc: 'TODO'
    },
    required: {
      type: 'Boolean',
      default: false,
      alias: 'requred',
      desc: 'TODO'
    },
    attribute_validation: {
      type: <<~TYPE,
        Optional[Tuple[Struct[{
          "min_length" => Variant[Integer, String],
          "max_length" => Variant[Integer, String],
          "regexp" => String,
        }]]]
      TYPE
      alias: 'attributeValidation',
      desc: 'TODO'
    },
    status: {
      type: <<~TYPE,
        Enum[
          "ACTIVE",
          "INACTIVE",
          "EXPIRED",
          "REGISTER"
        ]
      TYPE
      default: 'ACTIVE',
      desc: 'TODO'
    },
    saml1_uri: {
      type: 'Optional[String]',
      alias: 'saml1Uri',
      desc: 'TODO'
    },
    saml2_uri: {
      type: 'Optional[String]',
      alias: 'saml2Uri',
      desc: 'TODO'
    },
    origin: {
      type: 'String',
      default: 'gluuCustomPerson',
      desc: 'TODO'
    },
    name_id_type: {
      type: 'Optional[String]',
      alias: 'nameIdType',
      desc: 'TODO'
    },
    source_attribute: {
      type: 'Optional[String]',
      alias: 'sourceAttribute',
      desc: 'TODO'
    },
    ox_auth_claim_name: {
      type: 'Optional[String]',
      alias: 'oxAuthClaimName',
      desc: 'TODO'
    },
    see_also: {
      type: 'Optional[String]',
      alias: 'seeAlso',
      desc: 'TODO'
    },
    urn: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    base_dn: {
      type: 'Optional[String]',
      alias: 'baseDn',
      desc: 'TODO'
    }
  },
)
