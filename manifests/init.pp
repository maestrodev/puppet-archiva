# Copyright 2011 MaestroDev
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

class archiva($version, $user = "archiva", $group = "archiva", $service =
  "archiva", $installroot = "/usr/local", $home = "/var/local/archiva", 
  $apache_mirror = "http://archive.apache.org/dist/") {

  # wget from https://github.com/maestrodev/puppet-wget
  include wget

  File { owner => $user, group => $group, mode => "0600" }

  $installdir = "$installroot/apache-archiva-$version"
  $archive = "/usr/local/src/apache-archiva-${version}-bin.tar.gz"

  user { "$user":
    ensure     => present,
    home       => "$home",
    managehome => false,
    system     => true,
  }
  group { "$group":
    ensure  => present,
    require => User["$user"],
  }
  wget::fetch { "archiva_download":
    source => "$apache_mirror/archiva/binaries/apache-archiva-${version}-bin.tar.gz",
    destination => $archive,
  } ->
  exec { "archiva_untar":
    command => "tar zxf $archive",
    cwd     => "$installroot",
    creates => "$installdir",
    path    => ["/bin",],
    notify  => Service["archiva"],
  } ->
  file { "$installroot/$service":
    ensure  => link,
    target  => "$installdir",
  }
  if $::architecture == "x86_64" {
    file { "$installdir/bin/wrapper-linux-x86-32":
      ensure => absent,
      require => Exec["archiva_untar"],
    }
    file { "$installdir/lib/libwrapper-linux-x86-32.so":
      ensure => absent,
      require => Exec["archiva_untar"],
    }
  }
  file { "$home":
    ensure => directory,
    recurse => true,
  } ->
  file { "$home/tmp":
    ensure => directory,
  } ->
  file { "$home/logs":
    ensure => directory,
  } ->
  file { "$home/conf":
    ensure => directory,
  } ->
  file { "$home/conf/wrapper.conf": ensure => present, source => "$installdir/conf/wrapper.conf", } ->
  file { "$home/conf/shared.xml": ensure  => present, source => "$installdir/conf/shared.xml", } ->
  file { "$home/conf/jetty.xml": ensure  => present, source => "$installdir/conf/jetty.xml", } ->
  file { "/etc/profile.d/archiva.sh":
    owner   => "root",
    mode    => "0755",
    content => "export ARCHIVA_BASE=$home\n",
  } ->
  file { "/etc/init.d/$service":
    owner   => "root",
    mode    => "0755",
    content => template("archiva/archiva.erb"),
    require => Exec["archiva_untar"],
  } ->
  service { $service:
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    enable => true,
  }
}
