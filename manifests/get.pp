#This doesn't work because r10k ignores
#class blob::get (
#  Enum['absent', 'present'] $ensure    = 'present',
#  String                    $path      = blob::path,
#  String                    $account   = blob::account,
#  String                    $client_id = blob::client_id,
#  String                    $blob_path = blob::blob_path
#) {
#  blob_get { $path:
#    ensure    => $ensure,
#    account   => $account,
#    client_id => $client_id,
#    blob_path => $blob_path
#  }
#}
#
