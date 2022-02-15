# Acquire unzip package for Linux if needed
class blob::unzip {
  if $facts['os']['family'] != 'windows' {
    package { 'unzip':
      ensure => present
    }
  }
}
