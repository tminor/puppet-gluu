require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gluu_trust_relationship',
  docs: <<~DOC,
    Configures an SP's trust relationship with Shibboleth IDP 3.
  DOC
  features: ['canonicalize'],
  transport_type: 'ldap',
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether an organization configuration should be present or absent.',
      default: 'present'
    },
    description: {
      type: 'String',
      desc: 'TODO'
    },
    display_name: {
      type: 'String',
      behaviour: :namevar,
      alias: 'displayname',
      desc: 'TODO'
    },
    entity_id: {
      type: 'Optional[String]',
      alias: 'gluuentityid',
      desc: 'TODO'
    },
    entity_type: {
      type: 'Optional[String]',
      default: 'Single SP',
      alias: 'gluuentitytype',
      desc: 'TODO'
    },
    is_federation: {
      type: 'Boolean',
      default: false,
      alias: 'gluuisfederation',
      desc: 'TODO'
    },
    profile_configuration: {
      type: <<~TYPE,
        Optional[Struct[
          "include_attribute_statement"   => Boolean,
          "assertion_lifetime"            => Integer,
          "assertion_proxy_count"         => Integer,
          "sign_responses"                => Enum["conditional", "always", "never"],
          "sign_assertions"               => Enum["conditional", "always", "never"],
          "sign_requests"                 => Enum["conditional", "always", "never"],
          "encrypt_assertions"            => Enum["conditional", "always", "never"],
          "encrypt_name_ids"              => Enum["conditional", "always", "never"],
          "default_authentication_method" => Enum[
            "none",
            "urn:oasis:names:tc:SAML:2.0:ac:classes:InternetProtocol",
            "urn:oasis:names:tc:SAML:2.0:ac:classes:Password",
            "urn:oasis:names:tc:SAML:2.0:ac:classes:PasswordProtectedTransport"
          ],
          "name_id_format_precedence"     => Tuple[Enum[
            "urn:oasis:names:tc:SAML:2.0:nameid-format:persistent",
            "urn:oasis:names:tc:SAML:2.0:nameid-format:transient",
            "urn:oasis:names:tc:SAML:2.0:nameid-format:kerberos",
            "urn:oasis:names:tc:SAML:2.0:nameid-format:entity",
            "urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName",
            "urn:oasis:names:tc:SAML:1.1:nameid-format:WindowsDomainQualifiedName",
            "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified",
            "urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress"
          ], 1, default]
        ]]
      TYPE
      default: {
        'include_attribute_statement' => true,
        'assertion_lifetime' => 300_000,
        'assertion_proxy_count' => 0,
        'sign_responses' => 'always',
        'sign_assertions' => 'always',
        'sign_requests' => 'always',
        'encrypt_name_ids' => 'never',
        'encrypt_assertions' => 'never',
        'default_authentication_method' => 'none',
        'name_id_format_precedence' => [
          'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
          'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
          'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified',
        ]
      },
      alias: 'gluuprofileconfiguration',
      desc: 'TODO'
    },
    released_attributes: {
      type: 'Tuple[Optional[String], 0, default]',
      alias: 'gluureleasedattribute',
      desc: 'TODO'
    },
    saml_max_refresh_delay: {
      type: 'Optional[String]',
      default: 'PT8H',
      alias: 'gluusamlmaxrefreshdelay',
      desc: 'TODO'
    },
    metadata_file: {
      type: 'Optional[String]',
      alias: 'gluusamlspmetadatafn',
      behavior: :init_only,
      desc: 'TODO'
    },
    metadata_file_content: {
      type: 'String',
      behavior: :parameter,
      desc: 'TODO'
    },
    saml_sp_metadata_source_type: {
      type: 'Optional[String]',
      default: 'file',
      alias: 'gluusamlspmetadatasourcetype',
      desc: 'TODO'
    },
    specific_relying_party_config: {
      type: 'Boolean',
      default: true,
      alias: 'gluuspecificrelyingpartyconfig',
      desc: 'TODO'
    },
    status: {
      type: 'Optional[String]',
      default: 'active',
      alias: 'gluustatus',
      desc: 'TODO'
    },
  },
)
