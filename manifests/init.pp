# Class: blob
# This doesn't work because r10k ignores
class blob (
  Enum['absent', 'present'] $ensure,
  String                    $path,
  String                    $account,
  String                    $client_id,
  String                    $blob_path,
  String                    $owner,
  String                    $mode
) {
  contain blob::get

  file { 'this':
    path  => $path,
    owner => $owner,
    mode  => $mode
  }
}
