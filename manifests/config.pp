#
# Define squid::config
#

define squid::config (  
  $aclname            = undef,
  $type               = undef,
  $source             = undef,
  $destination        = undef,
  $cache_peer_options = undef,
  ){
 
  notice ($aclname)
  $aclname = $aclname
  file { "/etc/squid3/${title}.conf":
    mode    => "600",
    content => template('squid/config.erb'),
    require => File['/etc/squid3/squid.conf'],
   }

 }