execute "yum update" do
  user "root"
  command "yum -y update"
end

execute 'Install Development tools' do
  user "root"
  command 'yum -y groupinstall --skip-broken "Development Tools"'
end

package 'http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm' do
  not_if 'rpm -q nginx-release-centos-6-0.el6.ngx.noarch'
end

package "nginx" do
  action :install
end

remote_file "/etc/nginx/conf.d/idea_kanban.conf" do
  owner "nginx"
  group "nginx"
  source "./confs/nginx/idea_kanban.conf"
end

remote_file "/etc/nginx/conf.d/phpmyadmin.conf" do
  owner "nginx"
  group "nginx"
  source "./confs/nginx/phpmyadmin.conf"
end

execute "nginx default conf backup" do
  user "root"
  only_if "ls /etc/nginx/conf.d/default.conf"
  command "mv /etc/nginx/conf.d/default.conf /etc/nginx/conf.d/default.conf.org"
end

package "http://ftp.iij.ad.jp/pub/linux/fedora/epel/7/x86_64/e/epel-release-7-5.noarch.rpm" do
 not_if "rpm -q epel-release-7-5.noarch"
end

package "http://rpms.famillecollet.com/enterprise/remi-release-6.rpm" do
 not_if "rpm -q remi-release-6.6-2.el6.remi.noarch"
end

execute "php install" do
  user "root"
  command "yum -y install --enablerepo=remi --enablerepo=remi-php56 php php-opcache php-devel php-mbstring php-mcrypt php-mysqlnd php-phpunit-PHPUnit php-pecl-xdebug php-pecl-xhprof php-fpm wget"
end

execute "composer install" do
  user "root"
  not_if "which composer"
  command <<-EOH
curl -sS https://getcomposer.org/installer | php
mv ~/composer.phar /usr//bin/composer
command composer config -g github-oauth.github.com #{node["github-token"]}
composer self-update
EOH
end

# execute "install fuelphp" do
#   user "root"
#   cwd "/home/www/idea/"
#   command <<-EOH
# composer config -g repositories.packagist composer https://packagist.jp
# composer update
# php oil refine install
# EOH
# end

execute "php-fpm default conf backup" do
  user "root"
  only_if "ls /etc/php-fpm.d/www.conf"
  command "mv /etc/php-fpm.d/www.conf /etc/php-fpm.d/www.conf.org"
end

remote_file "/etc/php-fpm.d/www.conf" do
  owner "nginx"
  group "nginx"
  source "./confs/php-fpm/www.conf"
end

execute "rpm mariadb" do
  user "root"
  command "rpm --import https://yum.mariadb.org/RPM-GPG-KEY-MariaDB"
end

remote_file "/etc/yum.repos.d/mariadb.repo" do
  owner "root"
  group "root"
  source "./confs/mariadb/mariadb.repo"
end

execute "install mariadb" do
  user "root"
  command "yum -y install MariaDB-devel MariaDB-client MariaDB-server"
end

execute "download phpmyadmin" do
  user "root"
  not_if "ls /var/www/html/phpmyadmin"
  command "wget https://files.phpmyadmin.net/phpMyAdmin/4.6.0/phpMyAdmin-4.6.0-all-languages.zip && unzip phpMyAdmin-4.6.0-all-languages.zip"
end

execute "install phpmyadmin" do
  user "root"
  not_if "ls /var/www/html/phpmyadmin"
  command "mv phpMyAdmin-4.6.0-all-languages /var/www/html/phpmyadmin && chown -R nginx /var/www/html/phpmyadmin"
end

execute "chmod files" do
  user "root"
  command <<-EOH
chmod 777 /var/lib/php/session
chmod 777 /var/log/php-fpm
EOH
end

service "php-fpm" do
  user "root"
  action :start
end

execute "chmod php-fpm.sock" do
  user "root"
  command "chmod 777 /var/run/php-fpm/php-fpm.sock"
end

service "nginx" do
  user "root"
  action :restart
end
