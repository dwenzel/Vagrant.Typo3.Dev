execute "apt-get update"
#execute "apt-get -y -q upgrade"

packages = ["php5", "php5-cli", "php-pear", "php5-mysql", "php5-gd", "graphicsmagick"]

packages.each do |p|
  package p
end

execute "pear upgrade-all"

# get blank package
execute "cd /tmp && wget get.typo3.org/blank -O /tmp/blank.tgz" do
  not_if do
    File.exists?("/var/www/typo3")
  end
end

execute "sudo tar xzf /tmp/blank.tgz -C /var/www/ --strip-components=1" do
  only_if do
    File.exists?("/tmp/blank.tgz")
  end
end
 
#execute "wget http://prdownloads.sourceforge.net/typo3/introductionpackage-6.0.4.tar.gz -O /var/www/html/intro.tgz" do
#  not_if do
#    File.exists?("/var/www/html/intro.tgz")
#  end
#end

#execute "cd /var/www/html && sudo tar xzf intro.tgz --strip-components=1" do
#  only_if do
#    File.exists?("/var/www/html/intro.tgz")
#  end
#end

directory "/var/www" do
  owner "www-data"
  group "www-data"
  mode "0777"
end

#directory "/var/www/html/uploads" do
#  not_if do 
#    File.exists?("/var/www/html/uploads") && File.directory?("/var/www/html/uploads")
#  end
#  action :create
#  owner "www-data"
#  group "www-data"
#end

directories = ["uploads", "typo3conf", "typo3temp", "fileadmin"]

directories.each do |d| 
 execute "chmod -R 777 /var/www/" + d
end

file "/tmp/blank.tgz" do
  only_if do
    File.exists?("/tmp/blank.tgz")
  end
  action :delete
end

# add apache default site
cookbook_file "/etc/apache2/sites-enabled/000-default" do
  source "000-default" 
  mode "0644"
end

# replace php.ini
cookbook_file "/etc/php5/apache2/php.ini" do
  source "php.ini"
  mode "0644"
end

# create empty database
execute "mysql -uroot -ptypo3 -e 'CREATE DATABASE IF NOT EXISTS typo3;'"

execute "touch /var/www/typo3conf/ENABLE_INSTALL_TOOL"

execute "a2enmod rewrite"

service "apache2" do
	action :restart
end

# start mailcatcher
execute "mailcatcher --ip=0.0.0.0"

# the following does not work since the mailcatcher recipe does not provide a
# start / stop skript under init.d 
# It seems mailcatcher starts only after a halt of the virtual machine
#service "mailcatcher" do
#	action :restart
#end

