# Class: vhosts
#
# This class manages web vhosts.
#
# Parameters:
#
#
# Actions:
#   Manages apache and apache vhosts.
#
# Requires:
#
# Sample Usage:
#
#   include "vhosts"
#
#   vhosts::vhost { "foo.bar.com":
#       vhost => "foo",
#       domain => "bar.com"
#   }

class vhosts {

	file{"/usr/local/sbin/backup_vhost":
		ensure => present,
		owner => 'root',
		group => 'root',
		mode => '700',
		source => 'puppet:///modules/vhosts/backup_vhost',
	}

	define vhost($vhost, $domain, $vhost_user=false, $vhost_group=false){
		if $vhost_user {
			$user = $vhost_user
		} else {
			$user = "${vhost}.${domain}"
		}

		if $vhost_group {
			$group = $vhost_group
		} else {
			$group = "${vhost}.${domain}"
		}

		user{"$user":
			ensure => present,
			home => "/var/www/${domain}/${vhost}/",
		}

		# this is isn't needed with debian
		# group{"$group":
		# 	ensure => present,
		# }

		# this is a weird workaround that is needed because recursive creation of
		# direcotries isn't supported (mkdir -p)
		if defined(File["/var/www/${domain}/"]) {
			file{"/var/www/${domain}/${vhost}/":
				ensure => directory,
				owner => "${user}",
				group => "${group}",
			}
		} else {
			file{"/var/www/${domain}/":
				ensure => directory,
			}
			file{"/var/www/${domain}/${vhost}/":
				ensure => directory,
				owner => "${user}",
				group => "${group}",
			}
		}
		file{"/var/www/${domain}/${vhost}/configs/":
			ensure => directory,
			owner => "root",
			group => "root",
		}
		file{"/var/www/${domain}/${vhost}/htdocs/":
			ensure => directory,
			owner => "${user}",
			group => "${group}",
		}
		file{"/var/www/${domain}/${vhost}/logs/":
			ensure => directory,
		}
		cron{"${vhost}.${domain}_backup":
			command => "perl -e 'sleep rand 1800';/usr/local/sbin/backup_vhost ${domain} ${vhost}",
			user => "root",
			minute => fqdn_rand(60)
		}
	}
}
