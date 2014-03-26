puppet-squid
===================

Puppet module to for installing reverse proxy server based on squid


Parameters
-------------
All parameters are read from defaults in init.pp and can be overwritten by hiera or The foreman
Defaults of service name and location is read from params.pp based on the operating system. 

When configuration is changed the manifest will run a squid(3) -k parse first before restarting the service, if the parse is unsuccesfull then the config will not be applied and the system will keep running with the old configuration. This should make changes to the config slightly safer. 

General squid parameters:
```
  $squid_version                  = 'latest',
  $visible_hostname               = $fqdn,
  $http_port            		  = ['80 accel vhost'],
  $cache_mem                  	  = '256 MB',
  $maximum_object_size            = '4096 KB',
  $maximum_object_size_in_memory  = '512 KB',
```
Reverse proxy settings
Notes: 
- $acl_hash title is not used in config, just make sure this is unique
- Every aclname of an acl_hash item must have a matching cache_peer in the cache_peer_hash. 
- Duplicate aclnames with different rules are possible
- cache_peer_hash title is the aclname from which access to the destination is allowed.

Example: 
```
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
```
results in config: 
connecting to the server using url: www.testing.org/test will match to acl : sites_2 and access is allowed to cache_peer 10.1.1.11,
cache peer 10.1.1.11 is created with options as specified in the config. 

```
acl sites_2 url_regex -i www.testing.org/ 
acl sites_2 url_regex -i www.testsite..../test 
acl sites_1 dstdomain http://testsite.com/site3

cache_peer 10.1.1.11 parent 80 0 no-query originserver login=PASS name=10.1.1.11
http_access allow sites_2
cache_peer_access 10.1.1.11 allow sites_2
cache_peer 10.1.1.10 parent 80 0 no-query originserver name=10.1.1.10
http_access allow sites_1
cache_peer_access 10.1.1.10 allow sites_1
```



Classes
-------------
squid


Dependencies
-------------


Examples
-------------

Puppet code
```
class { squid: }
```
Result
-------------


Limitations
-------------
This module has been built on and tested against Puppet 3 and higher.

The module has been tested on:
- Ubuntu 12.04LTS 


Authors
-------------
Author Name <hugo.vanduijn@naturalis.nl>
Based on the thias/puppet-squid3 module.

