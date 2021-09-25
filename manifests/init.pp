# @summary Manage Gluu Server
#
# @example
#   class { 'gluu':
#     ldap_admin_pass    => 'abc123',
#     oxtrust_admin_pass => 'abc123',
#     api_key_pass       => 'secret',
#   }
#
# @param manage_install
#   Whether to install Gluu Server from an upstream package. The
#   default value is `true`.
# @param os
#   This value is used to construct the URL used to fetch the Gluu
#   Server package during a manged installation. The default value is
#   determined via facts.
# @param download_extension
#   Determines which type of package to download.
# @param ldap_admin_pass
#   The password used to authenticate against Gluu's LDAP backend.
# @param version
#   The version of Gluu Server to install. Defaults to `4.2.3`.
# @param oxtrust_api_jar_url
#   The URL used to fetch the oxTrust API JAR.
# @param server_hostname
#   The hostname used by Gluu to identify itself. The default value is
#   configured via facts.
# @param server_ip_address
#   The IP address used by Gluu to configure `httpd`.
# @param oxtrust_admin_pass
#   The password used to authenticate via oxTrust's GUI.
# @param api_key_pass
#   The password used to decrypt the Java keystore used to store API
#   keys.
# @param install_local_opendj
#   Whether to install OpenDJ locally. The default value is `true`.
# @param install_passport
#   Whether to install Passport. The default value is `true`.
# @param install_shibboleth_idp
#   Whether to install Shibboleth IDP. The default value is `true`.
# @param cert_info
#   A hash containing information used to generate a self signed
#   certificate for Gluu.
class gluu (
  Boolean $manage_install           = true,
  String  $os                       = join(
    [
      $facts['os']['name'],
      $facts['os']['release']['major'],
    ],
    '',
  ).downcase,
  String  $download_extension       = '.rpm',
  Hash    $cert_info                = {
    city     => 'New York',
    country  => 'US',
    state    => 'NY',
    org_name => 'Gluu Server',
    email    => 'foo@example.com',
  },
  String  $ldap_admin_pass          = undef,
  String  $version                  = '4.3.0-207',
  Variant[StdLib::HTTPUrl, Stdlib::HTTPSUrl]
          $oxtrust_api_jar_url      = "https://ox.gluu.org/maven/org/gluu/oxtrust-api-server/${version}.Final/oxtrust-api-server-${version}.Final.jar",
  String  $server_hostname          = 'localhost',
  String  $server_ip_address        = '127.0.0.1',
  String  $oxtrust_admin_pass       = undef,
  String  $api_key_pass             = 'secret',
  Boolean $install_local_opendj     = false,
  Boolean $install_passport         = true,
  Boolean $install_shibboleth_idp   = true,
  Integer $api_port                 = 443,
  Integer $ldap_port                = 636,
  String  $host_name                = 'localhost',
  String  $ldap_username           = 'cn=directory manager',
) {
  contain gluu::install

  gluu_configuration { 'configuration':
    ensure           => present,
    require          => Exec['gluu setup'],
    passport_enabled => $install_passport,
    saml_enabled     => $install_shibboleth_idp,
    api_config       => {
      password  => $api_key_pass,
      host_name => $host_name,
      port      => $api_port,
    },
    ldap_config      => {
      password  => $ldap_admin_pass,
      host_name => $host_name,
      port      => $ldap_port,
      username  => $ldap_username,
    },
  }
}
