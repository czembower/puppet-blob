# blob

## Table of Contents

1. [Description](#description)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Limitations - OS compatibility, etc.](#limitations)

## Description

A simple module that downloads objects from Azure blob storage, using the Client ID
parameter associated with a User-Assigned Managed Identity

## Usage

```
blob { '/tmp/myBlob.txt':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
  blob_path => 'myStorageContainer/myBlob.txt',
}
```

## Limitations

This module currently only supports User-Assigned Managed Identity as the authentication
mechanism. This requires the Puppet client system to be a machine running within the Azure
environment with appropriately scoped access permission. Alternate methods require sensitive
access credentials to be present in the manifest. In contrast, the client_id paramter is 
bound to a verified identity, and therefore carries a considerably lower risk factor.
