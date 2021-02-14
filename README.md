# puppet-blob

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Limitations](#limitations)

## Description

A simple Puppet module that downloads objects from Azure blob storage, using the Client ID
parameter associated with a User-Assigned Managed Identity as the authentication mechanism.

Also included are two custom facts:
- az_meta - full output from the Azure Metadata Service at the '/metadata/instance' endpoint
- client_id - the value of the 'clientId' tag, if is exists

## Usage

```
blob { '/tmp/myBlob.txt':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
  blob_path => 'myStorageContainer/myBlob.txt',
  mode      => 0644
}
```

Optionally, the client_id parameter can be sourced from an included custom fact that reads
the client_id from an Azure tag named "clientId" if it exists:

```
blob { '/tmp/myBlob.txt':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => $::client_id,
  blob_path => 'myStorageContainer/myBlob.txt',
  mode      => 0644
}
```

This method facilitates integration with infrastructure-as-code tools (such as Terraform)
such that a compute resource, managed identity, and access controls can all be defined 
programatically.

## Limitations

This module currently only supports User-Assigned Managed Identity as the authentication
mechanism. This requires the Puppet client system to be a machine running within the Azure
environment with appropriately scoped access permission. Alternate methods require sensitive
credentials to be present in the manifest. In contrast, the 'client ID' method is bound to
a verified identity and therefore carries a considerably lower risk factor.

The 'mode' parameter is currently implemented in a rudimentary fashion that simply applies
the defined mode after the object is retrieved from Blob. Ongoing enforcement of posix/windows
file permissions should be managed with a more appropriate method. 