require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gluu_api/gluu_api'))
require 'ruby-saml'
require 'openssl'

class Puppet::Provider::GluuPassportProvider::GluuPassportProvider < Puppet::Provider::GluuApi::GluuApi
  def get(context)
    _get('passport/providers', context)
  end

  def set(context, changes)
    _set('passport/providers', context, changes)
  end

  def parse_metadata(uri)
    file_path = URI.parse(uri).path
    metadata_parser = OneLogin::RubySaml::IdpMetadataParser.new

    metadata_parser.parse(File.read(file_path))
  end

  def create_idp_options(metadata = nil, opts = {})
    opts = {} if opts.nil?
    if metadata
      opts[:authnRequestBinding] = simplify_assertion_binding(
        metadata.assertion_consumer_service_binding
      ) unless opts[:authnRequestBinding]
      opts[:cert] = extract_signing_cert(metadata) unless opts[:cert]
      opts[:issuer] = metadata.idp_entity_id unless opts[:issuer]
      opts[:entryPoint] = metadata.idp_sso_service_url unless opts[:entryPoint]
    end
    opts[:skipRequestCompression] = true

    opts
  end

  def simplify_assertion_binding(str)
    match = str.match(/(?:[^:]+:)+(?<assertion_binding>.*)/)

    match[:assertion_binding]
  end

  def extract_signing_cert(metadata)
    if metadata.idp_cert_multi.nil?
      metadata.idp_cert.gsub(/[[:space:]]*/, '')
    else
      metadata.idp_cert_multi[:signing].find do |cert|
        cert_text = [
          "-----BEGIN CERTIFICATE-----",
          cert,
          "-----END CERTIFICATE-----"
        ].join("\n")
        cert = OpenSSL::X509::Certificate.new(cert_text)

        cert.not_after > Time.now
      end
    end
  end

  def canonicalize(_context, resources)
    resources.each do |r|
      if r[:metadata_file]
        metadata = parse_metadata(r[:metadata_file])
        r[:options] = create_idp_options(
          metadata,
          r[:options],
        )
        r.delete(:metadata_file)
      else
        r[:options] = create_idp_options(nil, r[:options])
      end
    end

    resources
  end
end
