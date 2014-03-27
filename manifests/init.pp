# == Class: squid
#
#
class squid (
  $visible_hostname               = $fqdn,
  $http_port                      = ['80 accel vhost'],
  $cache_mem                      = '256 MB',
  $maximum_object_size            = '4096 KB',
  $maximum_object_size_in_memory  = '512 KB',
  $acl_hash                       = { 'acl1' => { 
                                        'aclname'            => 'sites_1',
                                        'type'               => 'dstdomain',
                                        'content'            => 'http://testsite.com/site3',
                                    },
                                      'acl2' => {
                                        'aclname'            => 'sites_2',
                                        'type'               => 'url_regex -i',
                                        'content'            => 'www.testsite..../test',
                                    },
                                      'acl3' => {
                                        'aclname'            => 'sites_2',
                                        'type'               => 'url_regex -i',
                                        'content'            => 'www.testing.org/',
                                    }
                                  },
  $cache_peer_hash                = { 'sites_1' => { 
                                        'destination'         => '10.1.1.10',
                                        'cache_peer_options'  => 'parent 80 0 no-query originserver'
                                     },
                                      'sites_2' => { 
                                        'destination'         => '10.1.1.11',
                                        'cache_peer_options'  => 'parent 80 0 no-query originserver login=PASS'
                                     }
                                    }
) inherits ::squid::params {

  package { $package_name: 
    ensure => "installed",
  }

  service { $service_name:
    enable    => true,
    ensure    => running,
    restart   => "service ${service_name} reload",
    path      => ['/sbin', '/usr/sbin'],
    hasstatus => true,
    require   => [Package[$package_name],Exec['testconfig']]
  }

  exec { 'testconfig':
    command   => "/usr/sbin/${service_name} -k parse"
  }

  file { $config_file:
    require => Package[$package_name],
    notify  => Service[$service_name],
    content => template('squid/squid.conf.erb'),
  }


}
