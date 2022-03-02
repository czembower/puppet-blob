# puppet-blob

## Table of Contents

1. [Description](#description)
1. [Usage](#usage)
1. [Limitations](#limitations)

## Description

A simple Puppet module that downloads objects from Azure blob storage, using the Client ID
parameter associated with a User-Assigned Managed Identity as the authentication mechanism.

Optionally, the downloaded object can be unzipped, and permissions of the object and/or 
unzipped files can be managed by specifying the 'mode' parameter.

For convenience, a 'client_id' custom fact is provided as a means to source the Azure User-Assigned
Managed Identity client-id value from an Azure Tag 'clientId'

- client_id - the value of the 'clientId' tag, if it exists.

## Usage

```puppet
blob { '/tmp/myBlob.zip':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx',
  blob_path => 'myStorageContainer/myBlob.zip',
  mode      => '0644',
  unzip     => true,
  creates   => '/tmp/myBlob'
}
```

Optionally, the client_id parameter can be sourced from an included custom fact that reads
the client_id from an Azure tag named "clientId" if it exists:

```puppet
blob { '/tmp/myBlob.txt':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => $facts['client_id'],
  blob_path => 'myStorageContainer/myBlob.txt',
}
```

This method facilitates integration with infrastructure-as-code tools (e.g. Terraform)
such that a compute resource, managed identity, and access controls can all be defined 
programatically, without commiting sensitive data to your repository.

Microsoft azcopy can optionally be used to provide increased performance:

```puppet
blob { '/tmp/veryLargeFile.zip':
  ensure    => present,
  account   => 'myBlobStorageAccountName',
  client_id => $facts['client_id'],
  blob_path => 'myStorageContainer/veryLargeFile.zip',
  azcopy    => true
}
```

### Parameters

- `ensure`: Whether object should be present/absent on the local filesystem (default: present)
- `path`: \[string\] Where to store the object on the local system (optional - implied by resource name)
- `account`: \[string\] Azure Storage Account name (required)
- `client_id`: \[string\] The Client ID of the associated user-assigned managed identity (required)
- `blob_path`: \[string\] Path to the object in the form of \[container\]/\[path\]/\[to\]/\[object\] (required)
- `mode`: \[string\] Permissions that should be applied to the file after downloading (optional - default: undef)
- `unzip`: \[bool\] Whether to unzip downloaded Blob object (optional - default: false)
- `creates`: \[string\] File object created by the unzip process - controls mode/presence of extracted data, and will additionally purge the original zip archive after extraction (optional - default: undef)
- `azcopy`: \[bool\] Utilize the azcopy utility (recommended for large file transfers (optional - default: false)
- `mkdir`: \[bool\] Controls the creation of the target directory for unzipped objects (optional - default: true)

If 'mode' is defined and 'unzip' is selected, extracted files will be managed recursively. This is useful for directories.

On Windows systems, if 'creates' is specified, the value must be the full path to a single file that is extracted from the archive.
In this case, any management of file permissions should be handled with the Acl module (or similar) instead.

Leaving azcopy => false (default) will utilize Ruby standard library Net/Http to handle download operations.
This is perfectly suitable for common use, but in the case of large file transfers (over several GB), it is
recommended to enable the azcopy option. Doing so will result in installation of the latest version of azcopy
available from Microsoft at the following paths:

- `Linux:` /opt/azcopy/bin/azcopy
- `Windows:` C:/ProgramData/azcopy/bin/azcopy.exe

## Limitations

This module currently only supports User-Assigned Managed Identity as the authentication
mechanism. This requires the Puppet client system to be a machine running within the Azure
environment with appropriately scoped access permission. Alternate methods require sensitive
credentials to be present in the manifest. In contrast, the 'client ID' method is bound to
a verified identity and therefore carries a considerably lower risk factor.

Please open an issue at the Project URL if you would like to see support for alternative authentication methods.