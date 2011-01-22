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

		group{"$group":
			ensure => present,
		}

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
		file{"/var/www/${domain}/${vhost}/htdocs/":
			ensure => directory,
			owner => "${user}",
			group => "${group}",
		}
		file{"/var/www/${domain}/${vhost}/logs/":
			ensure => directory,
		}
	}
}
