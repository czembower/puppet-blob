# @summary
# A Puppet module that downloads Azure Blob objects.
#
# @param path
# Local filesystem path where the object should be downloaded. Optional, as the path parameter
# can alternatively be set using the resource name (path = namevar).
#
# @param account
# Azure Storage Account Name
#
# @param client_id
# The client_id of the associated user-managed identity
#
# @param blob_path
# Path to the object in the form of [container]/[path]/[to]/[object]
#
# @param unzip
# Optional param to unzip the object after downloading. Defaults to false.
#
# @param mode
# File mode that should be applied to the object after downloading. Defaults to undef.
# If mode is defined and unzip is selected, extracted files will be managed recursively.
#
# @param creates
# Optional parameter to specify the local filesystem path where the extracted zip file contents reside.
# Setting this option will apply the mode parameter to the unzipped files, ensure their existence,
# and will additionally delete the original object after extracting the zip archive.
# @param mode
# File mode that should be applied to the object after downloading. Defaults to undef.
#
# @param azcopy
# Optional parameter to specify whether to utilize the azcopy utility (recommended for large file transfers). Defaults to false.


define blob (
  String                      $account,
  String                      $client_id,
  String                      $blob_path,
  Enum['present', 'absent']   $ensure     = present,
  String                      $path       = $title,
  Optional[String]            $mode       = undef,
  Boolean                     $unzip      = false,
  Optional[String]            $creates    = undef,
  Boolean                     $azcopy     = false
) {

  if $creates {
    $file_asset  = $creates
  } else {
    $file_asset  = $path
  }

  if ($mode != undef) and ($unzip == true) {
    $recurse = true
  } else {
    $recurse = false
  }

  if $unzip {
    include blob::unzip
  }

  if $azcopy {
    include blob::azcopy
  }

  blob_get { $path:
    ensure     => $ensure,
    account    => $account,
    client_id  => $client_id,
    blob_path  => $blob_path,
    unzip      => $unzip,
    file_asset => $file_asset,
    azcopy     => $azcopy
  }

  file { $file_asset:
    ensure  => $ensure,
    mode    => $mode,
    recurse => $recurse,
    force   => true,
    require => Blob_get[$path]
  }

  if $creates {
    file { $path:
      ensure  => absent,
      mode    => $mode,
      recurse => true,
      force   => true,
      require => Blob_get[$path]
    }
  }
}
