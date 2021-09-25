require 'puppet/resource_api'

Puppet::ResourceApi.register_type(
  name: 'gluu_passport_provider',
  docs: <<~DOC,
  DOC
  transport_type: 'api',
  features: ['canonicalize'],
  attributes: {
    ensure: {
      type: 'Enum[present, absent]',
      desc: 'Whether an attribute should be present or absent.',
      default: 'present'
    },
    id: {
      type: 'String[1]',
      behavior: :namevar,
      desc: 'TODO'
    },
    display_name: {
      type: 'String[1]',
      alias: 'displayName',
      desc: 'TODO'
    },
    type: {
      type: 'String[1]',
      desc: 'TODO'
    },
    mapping: {
      type: 'String[1]',
      desc: 'TODO'
    },
    passport_strategy_id: {
      type: 'String[1]',
      alias: 'passportStrategyId',
      desc: 'TODO'
    },
    enabled: {
      type: 'Boolean',
      default: 'true',
      desc: 'TODO'
    },
    callback_url: {
      type: 'String[1]',
      alias: 'callbackUrl',
      desc: 'TODO'
    },
    request_for_email: {
      type: 'Optional[Boolean]',
      alias: 'requestForEmail',
      desc: 'TODO'
    },
    email_linking_safe: {
      type: 'Optional[Boolean]',
      alias: 'emailLinkingSafe',
      desc: 'TODO'
    },
    options: {
      type: <<~TYPE,
        Optional[Variant[Hash, Struct[
          Optional[additional_params]                 => Hash,
          Optional[additional_authorize_params]       => Hash,
          Optional[identifier_format]                 => String,
          Optional[want_assestions_signed]            => Boolean,
          Optional[accepted_clock_skew_ms]            => Integer,
          Optional[max_assertion_age_ms]              => Integer,
          Optional[attribute_consuming_service_index] => Integer,
          Optional[disable_requested_authn_context]   => Boolean,
          Optional[authn_context]                     => Variant[String, Tuple[String, 0, default]],
          Optional[rac_comparison]                    => Enum["exact", "minimum", "maximum", "better", ],
          Optional[force_authn]                       => Boolean,
          Optional[provider_name]                     => String,
          Optional[skip_request_compression]          => Boolean,
          Optional[authn_request_binding]             => Enum["HTTP-POST", "HTTP Redirect"],
          Optional[disable_request_acs_url]           => Boolean,
          Optional[scoping]                           => Struct[
            Optional[idp_list]     => Tuple[Struct[
              entries      => Tuple[Struct[
                provider_id    => String,
                Optional[name] => String,
                Optional[loc]  => String,
              ], 1, default],
              Optional[get_complete] => String,
            ], 1, default],
            Optional[proxy_count]  => Integer,
            Optional[requester_id] => String,
          ],
          Optional[validate_in_response_to]           => Boolean,
          Optional[request_id_expiration_period_ms]   => Integer,
          Optional[cache_provider]                    => String,
          Optional[idp_issuer]                        => String,
          Optional[pass_req_to_callback]              => Boolean,
          Optional[logout_url]                        => String,
          Optional[additional_logout_params]          => Hash,
          Optional[logout_callback_url]               => String,
        ]]]
      TYPE
      desc: 'See https://github.com/node-saml/passport-saml#config-parameter-details'
    },
    logo_img: {
      type: 'Optional[String]',
      desc: 'TODO'
    },
    metadata_file: {
      type: 'Optional[String]',
      desc: 'TODO'
    }
  },
)
