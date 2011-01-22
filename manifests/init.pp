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

	define vhost($vhost, $domain){
		# this is a weird workaround that is needed because recursive creation of
		# direcotries isn't supported (mkdir -p)
		if defined(File["/var/www/${domain}/"]) {
			file{"/var/www/${domain}/${vhost}/":
				ensure => directory
			}
		} else {
			file{"/var/www/${domain}/":
				ensure => directory
			}
			file{"/var/www/${domain}/${vhost}/":
				ensure => directory
			}
		}
		file{"/var/www/${domain}/${vhost}/htdocs/":
			ensure => directory
		}
		file{"/var/www/${domain}/${vhost}/logs/":
			ensure => directory
		}
	}
}
