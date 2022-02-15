# Acquire latest azcopy
class blob::azcopy {
  if $facts['os']['family'] == 'windows' {

      file { 'C:/ProgramData/azcopy':
        ensure => directory
      }

      file { 'C:/ProgramData/azcopy/src':
        ensure  => directory,
        require => File['C:/ProgramData/azcopy']
      }

      file { 'C:/ProgramData/azcopy/bin':
        ensure  => directory,
        require => File['C:/ProgramData/azcopy']
      }

      exec { 'azcopy_download':
        command  => 'Invoke-WebRequest -UseBasicParsing -Uri (Invoke-WebRequest -UseBasicParsing https://aka.ms/downloadazcopy-v10-windows -MaximumRedirection 0 -ErrorAction silentlycontinue).headers.location -OutFile C:/ProgramData/azcopy/src/azcopy.zip',
        unless   => 'if ((Test-Path C:/ProgramData/azcopy/src/azcopy.zip) -and (Get-Item C:/ProgramData/azcopy/src/azcopy.zip).Length -gt 100) { exit 0 } else { exit 1 }',
        provider => powershell,
        require  => File['C:/ProgramData/azcopy/src']
      }

      exec {'expand_azcopy':
        command  => 'Expand-Archive "C:/ProgramData/azcopy/src/azcopy.zip" -DestinationPath "C:/ProgramData/azcopy/src/"',
        unless   => 'if (Test-Path C:/ProgramData/azcopy/src/azcopy_windows*) { exit 0 } else { exit 1 }',
        provider => powershell,
        require  => Exec['azcopy_download']
      }

      exec {'install_azcopy':
        command  => 'Copy-Item "C:/ProgramData/azcopy/src/azcopy_windows*/azcopy.exe" -Destination "C:/ProgramData/azcopy/bin/"',
        unless   => 'if (Test-Path C:/ProgramData/azcopy/bin/azcopy.exe) { exit 0 } else { exit 1 }',
        provider => powershell,
        require  => [
          Exec['expand_azcopy'],
          File['C:/ProgramData/azcopy/bin']
        ]
      }

      file { 'C:/ProgramData/azcopy/bin/azcopy.exe':
        ensure  => present,
        mode    => '0777',
        require => Exec['install_azcopy']
      }
    }
    else {
      package { 'tar':
        ensure => present
      }

      file { '/opt/azcopy':
        ensure => directory
      }

      file { '/opt/azcopy/src':
        ensure  => directory,
        require => File['/opt/azcopy']
      }

      file { '/opt/azcopy/bin':
        ensure  => directory,
        require => File['/opt/azcopy']
      }

      exec { 'azcopy_download':
        command => '/usr/bin/env curl -L https://aka.ms/downloadazcopy-v10-linux -o /opt/azcopy/src/azcopy.tar.gz',
        unless  => '/bin/test -f /opt/azcopy/src/azcopy.tar.gz',
        require => File['/opt/azcopy/src']
      }

      exec {'expand_azcopy':
        command => '/usr/bin/env tar -xzf /opt/azcopy/src/azcopy.tar.gz',
        cwd     => '/opt/azcopy/src',
        unless  => 'test -d /opt/azcopy/src/azcopy_*',
        require => Exec['azcopy_download']
      }

      exec {'install_azcopy':
        command => '/usr/bin/env cp /opt/azcopy/src/$(ls /opt/azcopy/src/ | grep _)/azcopy /opt/azcopy/bin/',
        unless  => 'test -f /opt/azcopy/bin/azcopy',
        require => [
          Exec['expand_azcopy'],
          File['/opt/azcopy/bin']
        ]
      }

      file { '/opt/azcopy/bin/azcopy':
        ensure  => present,
        mode    => '0777',
        require => Exec['install_azcopy']
      }
    }
}
