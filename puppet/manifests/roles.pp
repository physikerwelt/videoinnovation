# == Roles for DOPA-VM
#
# A 'role' represents a set of software configurations required for
# giving this machine some special function.
#
# To enable a particular role on your instance, include it in the
# mediawiki-vagrant node definition in 'site.pp'.
#


# == Class: role::generic
# Configures common tools and shell enhancements.
class role::generic {
	include ::apache
	class { 'misc': }
	#class { 'apache':}
	@apache::site { 'default':
		ensure => absent,
	}

	@apache::site { 'video':
		ensure  => present,
		content => template('apache/video-apache-site.erb'),
	}	
#  apache::site { 'wiki':
#    ensure  => present,
#    content => template('mediawiki/mediawiki-apache-site.erb'),
#  }
}