require File.expand_path(File.join(File.dirname(__FILE__), '..', 'gluu_api/gluu_api'))

class Puppet::Provider::GluuTrustRelationship::GluuTrustRelationship < Puppet::Provider::GluuApi::GluuApi
  require 'securerandom'
  require 'uri'
  require 'digest/md5'
  require 'base64'

  include PuppetX::Gluu::Helpers::Xml
  include PuppetX::Gluu::Helpers::Ldap
  include PuppetX::Gluu::Helpers::Types

  class << self
    attr_accessor :context
    attr_reader :pc_aliases
  end

  @pc_aliases = {
    '@includeAttributeStatement' => 'include_attribute_statement',
    '@assertionLifetime' => 'assertion_lifetime',
    '@assertionProxyCount' => 'assertion_proxy_count',
    '@signResponses' => 'sign_responses',
    '@signAssertions' => 'sign_assertions',
    '@signRequests' => 'sign_requests',
    '@encryptAssertions' => 'encrypt_assertions',
    '@encryptNameIds' => 'encrypt_name_ids',
    '@defaultAuthenticationMethod' => 'default_authentication_method',
    '@nameIDFormatPrecedence' => 'name_id_format_precedence',
  }

  def get(context)
    self.class.context = context

    ldap_util = PuppetX::Gluu::Helpers::Ldap
    ldap = PuppetX::Gluu::Helpers::Ldap.bind(passwords[:ldap_admin_pass])
    filter = Net::LDAP::Filter.eq('objectClass', 'gluuSAMLconfig')
    trs = ldap_util.suppress_output { ldap.search(filter: filter, base: 'ou=trustRelationships,o=gluu').map(&:to_h) }
    ret = []
    namevar = context.type.namevars.first
    shib_path = '/opt/gluu-server/opt/shibboleth-idp/metadata/'

    trs.each do |tr|
      to_puppet                         = ldap_to_puppet(tr, context)
      to_puppet[:ensure]                = 'present'
      to_puppet[:title]                 = to_puppet[namevar]
      to_puppet[:profile_configuration] = prof_config_xml_to_hash(
        to_puppet[:profile_configuration],
      )

      metadata = shib_path + to_puppet[:metadata_file]
      to_puppet[:metadata_file_content] = Digest::MD5.hexdigest(File.read(metadata))
      to_puppet.delete(:metadata_file)

      ret << to_puppet
    end

    ret
  end

  def set(context, changes)
    changes.each do |name, change|
      should = change[:should]
      is     = change[:is]

      context.creating(name) { create(should, context) } if is[:ensure] == :absent
    end
  end

  def create(to_ldap, context)
    attr_map = attribute_inum_map
    to_ldap[:profile_configuration] = prof_config_hash_to_xml(to_ldap[:profile_configuration])
    metadata_file = fetch_metadata_file(to_ldap[:metadata_file])
    uuid = metadata_file.split('/')
                        .last
                        .match(%r{(?<uuid>.*)(?=-sp-metadata.xml)})[:uuid]
    to_ldap[:metadata_file] = metadata_file.split('/').last
    to_ldap[:released_attributes] = to_ldap[:released_attributes].map do |a|
      msg = "Couldn't find #{a} while attempting to create a trust relationship"
      attr_map[a].nil? ? Puppet.warning(msg) && next : attr_map[a]
    end
    to_ldap[:entity_id] = get_entity_id(metadata_file)
    to_ldap = puppet_to_ldap(to_ldap, context)

    to_ldap[:inum] = uuid
    to_ldap[:objectclass] = ['gluuSAMLconfig', 'top']
    to_ldap[:o] = 'o=gluu'

    dn = "inum=#{uuid},ou=trustRelationships,o=gluu"
    ldap = PuppetX::Gluu::Helpers::Ldap.bind(passwords[:ldap_admin_pass])
    ldap.add(dn: dn, attributes: to_ldap)
  end

  def prof_config_xml_to_hash(prof_config)
    pc_type = parse_type_schema(
      self.class.context.type.attributes[:profile_configuration][:type],
    )
    xml_hash = Nori.new.parse(prof_config)
    xml_puppet_struct_transform(
      xml_hash['rp:ProfileConfiguration'],
      pc_type,
      self.class.pc_aliases,
      :to_puppet,
    )
  end

  def prof_config_hash_to_xml(prof_config)
    pc_type = parse_type_schema(
      self.class.context.type.attributes[:profile_configuration][:type],
    )
    xml_hash = {
      'rp:ProfileConfiguration' => xml_puppet_struct_transform(
        prof_config,
        pc_type,
        self.class.pc_aliases,
        :to_xml,
      )
    }
    xml_hash['rp:ProfileConfiguration']['@xsi:type'] = 'saml:SAML2SSOProfile'
    Gyoku.xml(xml_hash)
  end

  def fetch_metadata_file(uri, &block)
    shib_path     = '/opt/gluu-server/opt/shibboleth-idp/metadata'
    metadata_sums = metadata_file_checksums(shib_path)
    uri           = URI.parse(uri)
    # metadata        = Puppet::FileServing::Metadata.indirection.find(uri.path)
    # metadata.source = uri
    uuid           = SecureRandom.uuid
    target_name    = uuid + '-sp-metadata.xml'
    target_path    = shib_path + '/' + target_name
    source_path    = uri.path
    source_content = File.read(source_path)
    source_sum     = Digest::MD5.hexdigest(source_content)
    source_exists  = metadata_sums[source_sum]
    return source_exists if source_exists

    case uri.scheme
    # when 'puppet'
    #   req  = Puppet::Indirector::Request.new(:file_source_content, :find, uri.to_s, nil)
    #   conn = Puppet::Network::HttpPool.http_instance(req.server, req.port)
    #   req.do_request(:fileserver) do |r|
    #     conn.request_get(
    #       Puppet::Network::HTTP::API::IndirectedRoutes.request_to_uri(r),
    #       add_accept_encoding({'Accept' => 'binary'}),
    #       block,
    #     )
    #   end
    when 'file'
      target = Puppet::Type::File.new(
        path: target_path,
        content: source_content,
      )

      content = target.parameter(:content)
      target.write(content)
      target_name
    end
  end

  def metadata_file_checksums(path)
    metadata_sums = {}
    Dir.glob(path + '/*-sp-metadata.xml').each do |f|
      metadata_sums[Digest::MD5.hexdigest(File.read(f))] = f
    end

    metadata_sums
  end

  def attribute_inum_map
    access_token = authenticate
    attrs = JSON.parse(
      HTTParty.get(
        'https://localhost/identity/restv1/api/v1/attributes',
        headers: {
          'Authorization' => "Bearer #{access_token}",
          'Content-Type' => 'application/json'
        },
      ).body,
    )
    attr_map = {}
    attrs.map { |a| attr_map[a['displayName']] = a['dn'] }

    attr_map
  end

  def get_entity_id(metadata_path)
    metadata_hash = Nori.new.parse(File.read(metadata_path))
    metadata_hash['md:EntityDescriptor']['@entityID']
  end

  def canonicalize(_context, resources)
    attr_map = attribute_inum_map
    resources.each do |r|
      next if r[:released_attributes].first.match?(%r{^inum=[^,]+,})

      metadata_checksum = Digest::MD5.hexdigest(File.read(URI.parse(r[:metadata_file]).path))

      r[:metadata_file_content] = metadata_checksum
      r.delete(:metadata_file)

      r[:released_attributes] = r[:released_attributes].map do |a|
        msg = "Couldn't find #{a} while attempting to create a trust relationship"
        attr_map[a].nil? ? Puppet.warning(msg) && next : attr_map[a]
      end
    end
    resources
  end
end
