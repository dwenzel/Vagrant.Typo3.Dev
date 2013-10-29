class Chef::Recipe
  include FileHelper
end

require 'open-uri'
require 'json'
require 'digest/sha1'

# get blank package
execute "cd /tmp && wget get.typo3.org/blank -O /tmp/blank.tgz" do
  not_if do
    File.exists?("/var/www/typo3")
  end
end

# @todo test if checksum of existing blank.tqz equals checksum from typo3.org
execute "sudo tar xzf /tmp/blank.tgz -C /var/www/ --strip-components=1" do
  only_if do
    File.exists?("/tmp/blank.tgz")
  end
end
 
#if Chef::Config[:solo]
  missing_attrs = %w[
    version
  ].select { |attr| node['typo3'][attr].nil? }.map { |attr|%Q{node['version']['#{attr}']} }
  
  unless missing_attrs.empty?
  # @todo add note to Readme
    Chef::Application.fatal! "You must set #{missing_attrs.join(', ')}
      in chef-solo mode." \
        " For more information, see
        https://github.com/dwenzel/Vagrant.Typo3.Dev#chef-solo-note"
  end
#else
    # set default version
    node.set_unless['typo3']['version'] = "latest_stable"
    #node.save
#end

nodeVersion = node["typo3"]["version"]
t3SrcUri = 'http://get.typo3.org/json'

buffer = open(t3SrcUri, "UserAgent" => "Ruby-Wget").read
t3Sources = JSON.parse(buffer)

case
  when nodeVersion.start_with?("latest")
    # got a version label like "latest_stable" or "latest_oldstable"
    t3VersionNumber = t3Sources[nodeVersion]
    #puts t3VersionNumber
    unless t3VersionNumber.empty?
      mainVersion = t3VersionNumber.match(/(.*)\.(.*)/)[1..2].first
      loadUrl = t3Sources[mainVersion]["releases"][t3VersionNumber]["url"]["tar"]
      checksum = t3Sources[mainVersion]["releases"][t3VersionNumber]["checksums"]["tar"]["sha1"]
    end
  when nodeVersion.start_with?("introduction")
   # install introduction package
  
  when nodeVersion.start_with?("governement")

  when /(\d{1,2}).(\d{1,2})\.(\d{1,4})/.match(nodeVersion)
   # got a number like 12.34.1234 (major.minor.bugfix)
   puts "major.minor.bugfix " + nodeVersion
   #mainVersion = t3Sources[nodeVersion].match(/(.*)\.(.*)\.(.*)/)
   #puts "major: " + mainVersion
  when /(\d{1,2}).(\d{1,2})/.match(nodeVersion)
   # got a number like 12.34 (major.minor)
   puts "major.minor " + nodeVersion
  when /(\d{1,2})/.match(nodeVersion)
   # got a number like 12 (major.minor)
   puts "major " + nodeVersion
  else
  # got a version number?
  # @todo load source by version number 
end

tmpFile = "/tmp/source_" + t3VersionNumber + ".tgz"

unless loadUrl.empty? || File.exists?("/var/www/typo3_src-" + t3VersionNumber)
  Chef::Log.info('Loading TYPO3 source from: ' + loadUrl)
  File.open(tmpFile, 'wb')  do |file|
    file << open(loadUrl).read
    tarCmd = "sudo tar xzf " + tmpFile + " -C /var/www/"
    execute tarCmd do
      only_if do
        File.exists?(tmpFile)  && FileHelper.equals_checksum(checksum, tmpFile)
      end
    end
  end
end

Dir.chdir("/var/www") do
  if File.readlink("typo3_src") != ("typo3_src-" + t3VersionNumber)
   File.delete("typo3_src")
   File.symlink("typo3_src-" + t3VersionNumber, "typo3_src")
  end
end

#execute "apt-get update"
#execute "apt-get -y -q upgrade"

packages = ["php5", "php5-cli", "php-pear", "php5-mysql", "php5-gd", "graphicsmagick"]

packages.each do |p|
  package p
end

execute "pear upgrade-all"

directory "/var/www" do
  owner "www-data"
  group "www-data"
  mode "0777"
end


directories = ["uploads", "typo3conf", "typo3temp", "fileadmin"]

directories.each do |d| 
 execute "chmod -R 777 /var/www/" + d
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
unless `ps aux | grep mailcatche[r]` != ""
  execute "mailcatcher --ip=0.0.0.0"
end

# the following does not work since the mailcatcher recipe does not provide a
# start / stop skript under init.d 
# It seems mailcatcher starts only after a halt of the virtual machine
#service "mailcatcher" do
#	action :restart
#end

