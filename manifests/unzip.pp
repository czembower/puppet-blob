class blob::unzip {
  if $facts['os']['family'] != 'windows' {
    package { 'unzip':
      ensure => present
    }
  }
}
