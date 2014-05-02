node.override['php']['directives'] = {
  'date.timezone' => 'Europe/Warsaw'
}

# --------------------------------------------
# set up php
# --------------------------------------------

include_recipe "apt"
include_recipe "git"
include_recipe "composer"

apt_repository "php55" do
  uri "http://ppa.launchpad.net/ondrej/php5/ubuntu"
  distribution node['lsb']['codename']
  components ["main"]
  keyserver "keyserver.ubuntu.com"
  key "E5267A6C"
end

include_recipe 'php'

package "php5-intl" do
  action :install
end

package "php5-curl" do
  action :install
end

# --------------------------------------------
# set up php.init
# --------------------------------------------

template "#{node['php']['conf_dir']}/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(:directives => node['php']['directives'])
end

template "#{node['php']['cgi_conf_dir']}/php.ini" do
  source "php.ini.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(:directives => node['php']['directives'])
end

# --------------------------------------------
# set up acl
# --------------------------------------------

%w{acl augeas-tools}.each do |pkg|
  package pkg
end

execute "update_fstab" do
  command <<-EOF
      echo 'ins opt after /files/etc/fstab/*[file="/"]/opt[last()]
      set /files/etc/fstab/*[file="/"]/opt[last()] acl
      save' | augtool
      mount -o remount /
  EOF
  not_if "augtool match '/files/etc/fstab/*[file=\"/\" and count(opt[.=\"acl\"])=0]'"
end