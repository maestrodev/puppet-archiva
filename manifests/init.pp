class archiva {
	#wget it
	include wget

	user { "$archiva_user":
    ensure     => present,
    home       => "$archiva_home/$archiva_user",
    managehome => false,
    shell      => "/bin/false",
  } ->
  group { "$archiva_group":
    ensure  => present,
    require => User["$archiva_user"],
  } ->
  wget::fetch { "archiva_download":
    source => "http://mirror.cc.columbia.edu/pub/software/apache//archiva/binaries/apache-archiva-${archiva_version}-bin.tar.gz",
    destination => "/usr/local/src/apache-archiva-${archiva_version}-bin.tar.gz",
    require => [Group["$archiva_group"],Package["java-1.6.0-openjdk-devel"]],
  } ->
  exec { "archiva_untar":
    command => "tar xf /usr/local/src/apache-archiva-${archiva_version}-bin.tar.gz && chown -R $archiva_user:$archiva_group $archiva_home/apache-archiva-$archiva_version",
    cwd     => "$archiva_home",
    creates => "$archiva_home/apache-archiva-$archiva_version",
    path    => ["/bin",],
  } ->
  file { "$archiva_home/archiva":
    ensure  => "$archiva_home/apache-archiva-$archiva_version",
    require => Exec["archiva_untar"],
  } ->
  file { "$archiva_home/archiva/bin/linux":
    ensure  => "$archiva_home/archiva/bin/linux-x86-64",
    require => File["$archiva_home/archiva"],
  } ->
  file { "$archiva_home/archiva/bin/wrapper-linux-x86-32":
  	ensure => absent,
  } ->
  file { "$archiva_home/archiva/lib/libwrapper-linux-x86-32.so":
  	ensure => absent,
  } ->
  file { "/etc/init.d/archiva":
    ensure  => "$archiva_home/archiva/bin/archiva",
  } ->
  service { "archiva":
    name => "archiva",
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    enable => true,
  }
}