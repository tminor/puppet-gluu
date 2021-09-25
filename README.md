# gluu

This module is in early development! It currently installs and
configures Gluu Server v4 and oxTrust's API.

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with gluu](#setup)
    * [Setup requirements](#setup-requirements)
    * [Beginning with gluu](#beginning-with-gluu)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module can be used to manage Gluu Server without relying on its
oxTrust GUI.

## Setup

### Setup Requirements

Currently, this module only handles installation from Gluu's RPM. If
you want to install it in some other way, you'll have to do it
yourself.

### Beginning with `puppet_gluu`

To get started with this module, install and configure Gluu Server like so:

```puppet
class { 'gluu':
  ldap_admin_pass    => 'abc123',
  oxtrust_admin_pass => 'abc123',
  extra_install_opts => '--install-local-opendj',
  api_key_pass       => 'secret',
}
```

## Usage

To add a custom attribute, use the `gluu_attribute` resource:

```puppet
gluu_attribute { 'emailnid':
  require                   => Gluu_api['default'],
  saml1_uri                 => 'urn:gluu:dir:attribute-def:emailnid',
  saml2_uri                 => 'IDPEmail',
  name                      => 'emailnid',
  display_name              => 'emailnid',
  data_type                 => 'STRING',
  edit_type                 => ['ADMIN'],
  view_type                 => ['ADMIN', 'USER'],
  ox_scim_custom_attribute  => false,
  ox_multi_valued_attribute => false,
  custom                    => true,
  required                  => false,
  description               => 'NameID based on email',
  status                    => 'ACTIVE',
  origin                    => 'gluuCustomPerson',
  name_id_type              => 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress',
  source_attribute          => 'mail'
}
```

## Development

To debug this module locally while developing, use `podman`:

```bash
# Build the image
podman build . -t puppet-gluu-dev
# Now, start the container
podman run -it --name puppet-gluu --rm --privileged -v /path/to/puppet-gluu:/etc/puppetlabs/code/modules/gluu -p 127.0.0.1:4443:443/tcp -d puppet-gluu-dev
# Log into the container
podman exec -it puppet-gluu /bin/bash
# Use puppet apply to debug with the test.pp manifest
# puppet apply /etc/puppetlabs/code/modules/gluu/test.pp
```
