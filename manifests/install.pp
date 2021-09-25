# Private class.
class gluu::install {
  assert_private()

  if $gluu::manage_install {
    ensure_packages(['wget', 'openldap-clients'])

    package { 'gluu-server-nochroot':
      ensure => present,
    }

    Service { provider => systemd }

    # exec { 'tweak pam.d':
    #   onlyif  => "/bin/grep -P 'session\\s+include\\s+system-auth' ${gluu_path}/etc/pam.d/su",
    #   command => "/bin/sed -E -i '/session\\s+include\\s+system-auth/d' ${gluu_path}/etc/pam.d/su"
    # }

    $cert_opts = gluu::hash_to_options($gluu::cert_info)
    $extra_install_opts = join(
      [] + if $gluu::install_local_opendj {
        '--install-local-opendj'
      } + if $gluu::install_passport {
        '-p'
      } + if $gluu::install_shibboleth_idp {
      '-s'
      },
      ' '
    )
    $setup_command = @("SETUP"/Ln)
      /bin/bash -c \
        'source /etc/profile && \
        /install/community-edition-setup/setup.py -c -n -u \
        -host-name ${gluu::server_hostname} \
        -ip-address ${gluu::server_ip_address} \
        ${cert_opts} \
        -ldap-admin-password ${gluu::ldap_admin_pass} \
        -oxtrust-admin-password ${gluu::oxtrust_admin_pass} \
        ${extra_install_opts}'
      |-SETUP

    $props_file = '/install/community-edition-setup/setup.properties.last.enc'
    exec { 'gluu setup':
      unless  => "/bin/test -f ${props_file}",
      command => $setup_command,
      timeout => 0,
      cwd     => '/install/community-edition-setup/',
    }

    exec { 'install oxTrust API':
      require => Exec['gluu setup'],
      unless  => "/usr/bin/grep '/opt/gluu/jetty/identity/custom/libs/oxtrust-api-server-${gluu::version}.Final.jar</Set>' /opt/gluu/jetty/identity/webapps/identity.xml",
      command => '/usr/bin/python3 /install/community-edition-setup/oxtrustapi_setup.py',
    }

    # # Ensures that authentication has been configured before trying to
    # # create attributes.
    # Gluu_attribute {
    #   require => Gluu_api['default']
    # }
  }
}
