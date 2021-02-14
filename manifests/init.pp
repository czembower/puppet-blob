# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include blob
class blob (
  String                    $account,
  String                    $blob_path,
  String                    $path       = $title,
  String                    $client_id  = $::client_id,
  String                    $mode       = '0644',
  Enum['present', 'absent'] $ensure     = present
) {
  blob::get { 'this':
    ensure    => $ensure,
    account   => $account,
    blob_path => $blob_path,
    client_id => $client_id,
    mode      => $mode
  }

  file { 'this':
    path => $path,
    mode => $mode
  }
}

#class blob (
#  Enum['absent', 'present'] $ensure,
#  String                    $path,
#  String                    $account,
#  String                    $client_id,
#  String                    $blob_path,
#  String                    $owner,
#  String                    $mode
#) {
#  contain blob::get
#
#  file { 'this':
#    path  => $path,
#    owner => $owner,
#    mode  => $mode
#  }
#}
#
