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
    ensure  => link,
    target  => "$archiva_home/apache-archiva-$archiva_version",
    require => Exec["archiva_untar"],
  } ->
  file { "$archiva_home/archiva/bin/linux":
    ensure  => link,
    target  => "$archiva_home/archiva/bin/linux-x86-64",
    require => File["$archiva_home/archiva"],
  } ->
  file { "$archiva_home/archiva/bin/wrapper-linux-x86-32":
    ensure => absent,
  } ->
  file { "$archiva_home/archiva/lib/libwrapper-linux-x86-32.so":
    ensure => absent,
  } ->
  file { "/etc/init.d/archiva":
    ensure  => link,
    target  => "$archiva_home/archiva/bin/archiva",
  } ->
  service { "archiva":
    name => "archiva",
    ensure => running,
    hasrestart => true,
    hasstatus => true,
    enable => true,
  }
}