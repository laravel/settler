#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

ARCH=$(arch)

SKIP_PHP=false
SKIP_MYSQL=false
SKIP_MARIADB=true
SKIP_POSTGRESQL=false

echo "### Settler Build Configuration ###"
echo "ARCH             = ${ARCH}"
echo "SKIP_PHP         = ${SKIP_PHP}"
echo "SKIP_MYSQL       = ${SKIP_MYSQL}"
echo "SKIP_MARIADB     = ${SKIP_MARIADB}"
echo "SKIP_POSTGRESQL  = ${SKIP_POSTGRESQL}"
echo "### Settler Build Configuration ###"

# Update Package List
apt-get update

# Update System Packages
apt-get upgrade -y

# Force Locale
echo "LC_ALL=en_US.UTF-8" >> /etc/default/locale
locale-gen en_US.UTF-8

apt-get install -y software-properties-common curl gnupg debian-keyring debian-archive-keyring apt-transport-https \
ca-certificates

# Install Some PPAs
apt-add-repository ppa:ondrej/php -y

# NodeJS
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg
NODE_MAJOR=21
echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list

# PostgreSQL
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
# Import the repository signing key:
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys ACCC4CF8
wget -qO- https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo tee /etc/apt/trusted.gpg.d/pgdg.asc &>/dev/null

## Update Package Lists
apt-get update -y

# Install Some Basic Packages
apt-get install -y build-essential dos2unix gcc git git-lfs libmcrypt4 libpcre3-dev libpng-dev chrony unzip make pv \
python3-pip re2c supervisor unattended-upgrades whois vim cifs-utils bash-completion zsh graphviz avahi-daemon tshark

# Set My Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

# Install docker-ce
curl -fsSL https://get.docker.com | bash -s

# Enable vagrant user to run docker commands
usermod -aG docker vagrant

# Install docker-compose
curl \
    -L "https://github.com/docker/compose/releases/download/2.23.0/docker-compose-$(uname -s)-$(uname -m)" \
    -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Configure feature tracking path
mkdir -p /home/vagrant/.homestead-features

if "$SKIP_PHP"; then
  echo "SKIP_PHP is being used, so we're not installing PHP"
else
  # Install Generic PHP packages
  apt-get install -y --allow-change-held-packages \
  php-imagick php-memcached php-redis php-xdebug php-dev imagemagick mcrypt

  # PHP 5.6
  apt-get install -y --allow-change-held-packages \
  php5.6-bcmath php5.6-bz2 php5.6-cgi php5.6-cli php5.6-common php5.6-curl php5.6-dba php5.6-dev php5.6-enchant \
  php5.6-fpm php5.6-gd php5.6-gmp php5.6-imap php5.6-interbase php5.6-intl php5.6-json php5.6-ldap php5.6-mbstring \
  php5.6-mcrypt php5.6-mysql php5.6-odbc php5.6-opcache php5.6-pgsql php5.6-phpdbg php5.6-pspell php5.6-readline \
  php5.6-recode php5.6-snmp php5.6-soap php5.6-sqlite3 php5.6-sybase php5.6-tidy php5.6-xml php5.6-xmlrpc php5.6-xsl \
  php5.6-zip php5.6-imagick php5.6-memcached php5.6-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/5.6/cli/php.ini

  # Configure Xdebug
  echo "xdebug.remote_enable = 1" >> /etc/php/5.6/mods-available/xdebug.ini
  echo "xdebug.remote_connect_back = 1" >> /etc/php/5.6/mods-available/xdebug.ini
  echo "xdebug.remote_port = 9000" >> /etc/php/5.6/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/5.6/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/5.6/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/5.6/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/5.6/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/5.6/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/5.6/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/5.6/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/5.6/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/5.6/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/5.6/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/5.6/fpm/php.ini

  printf "[curl]\n" | tee -a /etc/php/5.6/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/5.6/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/5.6/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/5.6/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/5.6/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/5.6/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/5.6/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php56

  # PHP 7.0
  apt-get install -y --allow-change-held-packages \
  php7.0-bcmath php7.0-bz2 php7.0-cgi php7.0-cli php7.0-common php7.0-curl php7.0-dba php7.0-dev php7.0-enchant \
  php7.0-fpm php7.0-gd php7.0-gmp php7.0-imap php7.0-interbase php7.0-intl php7.0-json php7.0-ldap php7.0-mbstring \
  php7.0-mcrypt php7.0-mysql php7.0-odbc php7.0-opcache php7.0-pgsql php7.0-phpdbg php7.0-pspell php7.0-readline \
  php7.0-recode php7.0-snmp php7.0-soap php7.0-sqlite3 php7.0-sybase php7.0-tidy php7.0-xml php7.0-xmlrpc php7.0-xsl \
  php7.0-zip php7.0-imagick php7.0-memcached php7.0-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/cli/php.ini

  # Configure Xdebug
  echo "xdebug.remote_enable = 1" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_connect_back = 1" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.remote_port = 9000" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/7.0/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/7.0/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.0/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.0/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.0/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.0/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.0/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.0/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.0/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/7.0/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.0/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/7.0/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.0/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.0/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.0/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php70

  # PHP 7.1
  apt-get install -y --allow-change-held-packages \
  php7.1-bcmath php7.1-bz2 php7.1-cgi php7.1-cli php7.1-common php7.1-curl php7.1-dba php7.1-dev php7.1-enchant \
  php7.1-fpm php7.1-gd php7.1-gmp php7.1-imap php7.1-interbase php7.1-intl php7.1-json php7.1-ldap php7.1-mbstring \
  php7.1-mcrypt php7.1-mysql php7.1-odbc php7.1-opcache php7.1-pgsql php7.1-phpdbg php7.1-pspell php7.1-readline \
  php7.1-recode php7.1-snmp php7.1-soap php7.1-sqlite3 php7.1-sybase php7.1-tidy php7.1-xdebug php7.1-xml php7.1-xmlrpc \
  php7.1-xsl php7.1-zip php7.1-imagick php7.1-memcached php7.1-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/cli/php.ini

  # Configure Xdebug
  echo "xdebug.remote_enable = 1" >> /etc/php/7.1/mods-available/xdebug.ini
  echo "xdebug.remote_connect_back = 1" >> /etc/php/7.1/mods-available/xdebug.ini
  echo "xdebug.remote_port = 9000" >> /etc/php/7.1/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/7.1/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/7.1/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.1/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.1/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.1/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.1/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.1/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.1/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.1/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/7.1/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.1/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/7.1/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.1/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.1/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.1/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php71

  # PHP 7.2
  apt-get install -y --allow-change-held-packages \
  php7.2-bcmath php7.2-bz2 php7.2-dba php7.2-enchant php7.2-fpm php7.2-imap php7.2-interbase php7.2-intl \
  php7.2-mbstring php7.2-phpdbg php7.2-soap php7.2-sybase php7.2-xsl php7.2-zip php7.2-cgi php7.2-cli php7.2-common \
  php7.2-curl php7.2-dev php7.2-gd php7.2-gmp php7.2-json php7.2-ldap php7.2-mysql php7.2-odbc php7.2-opcache \
  php7.2-pgsql php7.2-pspell php7.2-readline php7.2-recode php7.2-snmp php7.2-sqlite3 php7.2-tidy php7.2-xdebug \
  php7.2-xml php7.2-xmlrpc php7.2-imagick php7.2-memcached php7.2-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/7.2/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/7.2/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/7.2/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/7.2/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/7.2/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.2/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.2/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.2/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.2/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.2/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.2/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.2/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/7.2/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.2/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/7.2/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.2/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/7.2/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/7.2/fpm/pool.d/www.conf

  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.2/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.2/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.2/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php72

  # PHP 7.3
  apt-get install -y --allow-change-held-packages \
  php7.3 php7.3-bcmath php7.3-bz2 php7.3-cgi php7.3-cli php7.3-common php7.3-curl php7.3-dba php7.3-dev php7.3-enchant \
  php7.3-fpm php7.3-gd php7.3-gmp php7.3-imap php7.3-interbase php7.3-intl php7.3-json php7.3-ldap php7.3-mbstring \
  php7.3-mysql php7.3-odbc php7.3-opcache php7.3-pgsql php7.3-phpdbg php7.3-pspell php7.3-readline php7.3-recode \
  php7.3-snmp php7.3-soap php7.3-sqlite3 php7.3-sybase php7.3-tidy php7.3-xdebug php7.3-xml php7.3-xmlrpc php7.3-xsl \
  php7.3-zip php7.3-imagick php7.3-memcached php7.3-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/7.3/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/7.3/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/7.3/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/7.3/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/7.3/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.3/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.3/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.3/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.3/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.3/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.3/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.3/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/7.3/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/7.3/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.3/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.3/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.3/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php73

  # PHP 7.4
  apt-get install -y --allow-change-held-packages \
  php7.4 php7.4-bcmath php7.4-bz2 php7.4-cgi php7.4-cli php7.4-common php7.4-curl php7.4-dba php7.4-dev \
  php7.4-enchant php7.4-fpm php7.4-gd php7.4-gmp php7.4-imap php7.4-interbase php7.4-intl php7.4-json php7.4-ldap \
  php7.4-mbstring php7.4-mysql php7.4-odbc php7.4-opcache php7.4-pgsql php7.4-phpdbg php7.4-pspell php7.4-readline \
  php7.4-snmp php7.4-soap php7.4-sqlite3 php7.4-sybase php7.4-tidy php7.4-xdebug php7.4-xml php7.4-xmlrpc php7.4-xsl \
  php7.4-zip php7.4-imagick php7.4-memcached php7.4-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/7.4/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/7.4/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/7.4/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/7.4/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/7.4/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/7.4/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/7.4/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/7.4/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/7.4/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/7.4/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/7.4/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/7.4/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/7.4/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/7.4/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/7.4/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/7.4/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php74

  # PHP 8.0
  apt-get install -y --allow-change-held-packages \
  php8.0 php8.0-bcmath php8.0-bz2 php8.0-cgi php8.0-cli php8.0-common php8.0-curl php8.0-dba php8.0-dev \
  php8.0-enchant php8.0-fpm php8.0-gd php8.0-gmp php8.0-imap php8.0-interbase php8.0-intl php8.0-ldap \
  php8.0-mbstring php8.0-mysql php8.0-odbc php8.0-opcache php8.0-pgsql php8.0-phpdbg php8.0-pspell php8.0-readline \
  php8.0-snmp php8.0-soap php8.0-sqlite3 php8.0-sybase php8.0-tidy php8.0-xdebug php8.0-xml php8.0-xmlrpc php8.0-xsl \
  php8.0-zip php8.0-imagick php8.0-memcached php8.0-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/8.0/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/8.0/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/8.0/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/8.0/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/8.0/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/8.0/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/8.0/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.0/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php80

  # PHP 8.1
  apt-get install -y --allow-change-held-packages \
  php8.1 php8.1-bcmath php8.1-bz2 php8.1-cgi php8.1-cli php8.1-common php8.1-curl php8.1-dba php8.1-dev \
  php8.1-enchant php8.1-fpm php8.1-gd php8.1-gmp php8.1-imap php8.1-interbase php8.1-intl php8.1-ldap \
  php8.1-mbstring php8.1-mysql php8.1-odbc php8.1-opcache php8.1-pgsql php8.1-phpdbg php8.1-pspell php8.1-readline \
  php8.1-snmp php8.1-soap php8.1-sqlite3 php8.1-sybase php8.1-tidy php8.1-xdebug php8.1-xml php8.1-xmlrpc php8.1-xsl \
  php8.1-zip php8.1-imagick php8.1-memcached php8.1-redis

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.1/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.1/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.1/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/8.1/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/8.1/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/8.1/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/8.1/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/8.1/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.1/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.1/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.1/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.1/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.1/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.1/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/8.1/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.1/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/8.1/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.1/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.1/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.1/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php81

  # PHP 8.2
  apt-get install -y --allow-change-held-packages \
  php8.2 php8.2-bcmath php8.2-bz2 php8.2-cgi php8.2-cli php8.2-common php8.2-curl php8.2-dba php8.2-dev \
  php8.2-enchant php8.2-fpm php8.2-gd php8.2-gmp php8.2-imap php8.2-interbase php8.2-intl php8.2-ldap \
  php8.2-mbstring php8.2-mysql php8.2-odbc php8.2-opcache php8.2-pgsql php8.2-phpdbg php8.2-pspell php8.2-readline \
  php8.2-snmp php8.2-soap php8.2-sqlite3 php8.2-sybase php8.2-tidy php8.2-xml php8.2-xsl \
  php8.2-zip php8.2-imagick php8.2-memcached php8.2-redis php8.2-xmlrpc php8.2-xdebug

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.2/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.2/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.2/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.2/cli/php.ini

  # Configure Xdebug
  echo "xdebug.mode = debug" >> /etc/php/8.2/mods-available/xdebug.ini
  echo "xdebug.discover_client_host = true" >> /etc/php/8.2/mods-available/xdebug.ini
  echo "xdebug.client_port = 9003" >> /etc/php/8.2/mods-available/xdebug.ini
  echo "xdebug.max_nesting_level = 512" >> /etc/php/8.2/mods-available/xdebug.ini
  echo "opcache.revalidate_freq = 0" >> /etc/php/8.2/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.2/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.2/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.2/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.2/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.2/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.2/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/8.2/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.2/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/8.2/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.2/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/8.2/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/8.2/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.2/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.2/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.2/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php82

  # PHP 8.3
  apt-get install -y --allow-change-held-packages \
  php8.3 php8.3-bcmath php8.3-bz2 php8.3-cgi php8.3-cli php8.3-common php8.3-curl php8.3-dba php8.3-dev \
  php8.3-enchant php8.3-fpm php8.3-gd php8.3-gmp php8.3-imap php8.3-interbase php8.3-intl php8.3-ldap \
  php8.3-mbstring php8.3-mysql php8.3-odbc php8.3-opcache php8.3-pgsql php8.3-phpdbg php8.3-pspell php8.3-readline \
  php8.3-snmp php8.3-soap php8.3-sqlite3 php8.3-sybase php8.3-tidy php8.3-xml php8.3-xsl \
  php8.3-zip
  # php8.3-imagick php8.3-memcached php8.3-redis php8.3-xmlrpc php8.3-xdebug

  # Configure php.ini for CLI
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.3/cli/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.3/cli/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.3/cli/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.3/cli/php.ini

  # Configure Xdebug
#  echo "xdebug.mode = debug" >> /etc/php/8.3/mods-available/xdebug.ini
#  echo "xdebug.discover_client_host = true" >> /etc/php/8.3/mods-available/xdebug.ini
#  echo "xdebug.client_port = 9003" >> /etc/php/8.3/mods-available/xdebug.ini
#  echo "xdebug.max_nesting_level = 512" >> /etc/php/8.3/mods-available/xdebug.ini
#  echo "opcache.revalidate_freq = 0" >> /etc/php/8.3/mods-available/opcache.ini

  # Configure php.ini for FPM
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.3/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.3/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.3/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.3/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.3/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.3/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.3/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/8.3/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.3/fpm/php.ini
  printf "[curl]\n" | tee -a /etc/php/8.3/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.3/fpm/php.ini

  # Configure FPM
  sed -i "s/user = www-data/user = vagrant/" /etc/php/8.3/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/8.3/fpm/pool.d/www.conf
  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.3/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.3/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.3/fpm/pool.d/www.conf

  touch /home/vagrant/.homestead-features/php8.3

  # Disable old PHP FPM
  systemctl disable php5.6-fpm
  systemctl disable php7.0-fpm
  systemctl disable php7.1-fpm
  systemctl disable php7.2-fpm
  systemctl disable php7.3-fpm
  systemctl disable php7.4-fpm
  systemctl disable php8.0-fpm
  systemctl disable php8.1-fpm
  systemctl disable php8.2-fpm

  update-alternatives --set php /usr/bin/php8.3
  update-alternatives --set php-config /usr/bin/php-config8.3
  update-alternatives --set phpize /usr/bin/phpize8.3

  # Install Composer
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
  chown -R vagrant:vagrant /home/vagrant/.config

  # Install Global Packages
  sudo su vagrant <<'EOF'
  /usr/local/bin/composer global require "laravel/envoy=^2.0"
  /usr/local/bin/composer global require "laravel/installer=^5.0"
  /usr/local/bin/composer global config --no-plugins allow-plugins.slince/composer-registry-manager true
  /usr/local/bin/composer global require "slince/composer-registry-manager=^2.0"
EOF

  # Install Apache
  apt-get install -y apache2 libapache2-mod-fcgid
  sed -i "s/www-data/vagrant/" /etc/apache2/envvars

  # Enable FPM
  a2enconf php8.3-fpm

  # Assume user wants mode_rewrite support
  sudo a2enmod rewrite

  # Turn on HTTPS support
  sudo a2enmod ssl

  # Turn on proxy & fcgi
  sudo a2enmod proxy proxy_fcgi

  # Turn on headers support
  sudo a2enmod headers actions alias

  # Add Mutex to config to prevent auto restart issues
  if [ -z "$(grep '^Mutex posixsem$' /etc/apache2/apache2.conf)" ]
  then
      echo 'Mutex posixsem' | sudo tee -a /etc/apache2/apache2.conf
  fi

  a2dissite 000-default
  systemctl disable apache2

  # Install Nginx
  apt-get install -y --allow-downgrades --allow-remove-essential --allow-change-held-packages nginx

  rm /etc/nginx/sites-enabled/default
  rm /etc/nginx/sites-available/default

  # Create a configuration file for Nginx overrides.
  mkdir -p /home/vagrant/.config/nginx
  chown -R vagrant:vagrant /home/vagrant
  touch /home/vagrant/.config/nginx/nginx.conf
  ln -sf /home/vagrant/.config/nginx/nginx.conf /etc/nginx/conf.d/nginx.conf

  # Setup Some PHP-FPM Options
  sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php/8.0/fpm/php.ini
  sed -i "s/display_errors = .*/display_errors = On/" /etc/php/8.0/fpm/php.ini
  sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.0/fpm/php.ini
  sed -i "s/memory_limit = .*/memory_limit = 512M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/upload_max_filesize = .*/upload_max_filesize = 100M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/post_max_size = .*/post_max_size = 100M/" /etc/php/8.0/fpm/php.ini
  sed -i "s/;date.timezone.*/date.timezone = UTC/" /etc/php/8.0/fpm/php.ini

  printf "[openssl]\n" | tee -a /etc/php/8.0/fpm/php.ini
  printf "openssl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini

  printf "[curl]\n" | tee -a /etc/php/8.0/fpm/php.ini
  printf "curl.cainfo = /etc/ssl/certs/ca-certificates.crt\n" | tee -a /etc/php/8.0/fpm/php.ini

  # Disable XDebug On The CLI
  sudo phpdismod -s cli xdebug

  # Set The Nginx & PHP-FPM User
  sed -i "s/user www-data;/user vagrant;/" /etc/nginx/nginx.conf
  sed -i "s/# server_names_hash_bucket_size.*/server_names_hash_bucket_size 64;/" /etc/nginx/nginx.conf
  sed -i "s/sendfile on;/sendfile on; client_max_body_size 100M;/" /etc/nginx/nginx.conf

  sed -i "s/user = www-data/user = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/group = www-data/group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf

  sed -i "s/listen\.owner.*/listen.owner = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/listen\.group.*/listen.group = vagrant/" /etc/php/8.0/fpm/pool.d/www.conf
  sed -i "s/;listen\.mode.*/listen.mode = 0666/" /etc/php/8.0/fpm/pool.d/www.conf

  service nginx restart
  service php8.3-fpm restart

  # Add Vagrant User To WWW-Data
  usermod -a -G www-data vagrant
  id vagrant
  groups vagrant

  # Install wp-cli
  curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
  chmod +x wp-cli.phar
  mv wp-cli.phar /usr/local/bin/wp

  # Add Composer Global Bin To Path
  printf "\nPATH=\"$(sudo su - vagrant -c 'composer config -g home 2>/dev/null')/vendor/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile
fi

# Install Node
apt-get install -y nodejs
/usr/bin/npm install -g npm
/usr/bin/npm install -g gulp-cli
/usr/bin/npm install -g bower
/usr/bin/npm install -g yarn
/usr/bin/npm install -g grunt-cli

# Install SQLite
apt-get install -y sqlite3 libsqlite3-dev

if "$SKIP_MYSQL"; then
  echo "SKIP_MYSQL is being used, so we're not installing MySQL"
  apt-get install -y mysql-client
else
  # Install MySQL
  echo "mysql-server mysql-server/root_password password secret" | debconf-set-selections
  echo "mysql-server mysql-server/root_password_again password secret" | debconf-set-selections
  apt-get install -y mysql-server

  # Configure MySQL 8 Remote Access and Native Pluggable Authentication
  cat > /etc/mysql/conf.d/mysqld.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
disable_log_bin
default_authentication_plugin = mysql_native_password
EOF

  # Configure MySQL Password Lifetime
  echo "default_password_lifetime = 0" >> /etc/mysql/mysql.conf.d/mysqld.cnf

  # Configure MySQL Remote Access
  sed -i '/^bind-address/s/bind-address.*=.*/bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
  service mysql restart

  export MYSQL_PWD=secret

  mysql --user="root" -e "ALTER USER 'root'@'localhost' IDENTIFIED BY 'secret';"
  mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;"
  mysql --user="root" -e "CREATE USER 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret';"
  mysql --user="root" -e "CREATE USER 'homestead'@'%' IDENTIFIED BY 'secret';"
  mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'0.0.0.0' WITH GRANT OPTION;"
  mysql --user="root" -e "GRANT ALL PRIVILEGES ON *.* TO 'homestead'@'%' WITH GRANT OPTION;"
  mysql --user="root" -e "FLUSH PRIVILEGES;"
  mysql --user="root" -e "CREATE DATABASE homestead character set UTF8mb4 collate utf8mb4_bin;"

  sudo tee /home/vagrant/.my.cnf <<EOL
[mysqld]
character-set-server=utf8mb4
collation-server=utf8mb4_bin
EOL
  service mysql restart
fi

if "$SKIP_MARIADB"; then
  echo "$SKIP_MARIADB is being used, so we're not installing MariaDB"
else
  # Disable Apparmor
  # See https://github.com/laravel/homestead/issues/629#issue-247524528
  service apparmor stop
  update-rc.d -f apparmor remove

  # Remove MySQL
  apt-get remove -y --purge mysql-server mysql-client mysql-common
  apt-get autoremove -y
  apt-get autoclean

  rm -rf /var/lib/mysql/*
  rm -rf /var/log/mysql
  rm -rf /etc/mysql

  # Add Maria PPA
  curl -LsS https://downloads.mariadb.com/MariaDB/mariadb_repo_setup | sudo bash

  echo "mariadb-server mysql-server/data-dir select ''" | debconf-set-selections
  echo "mariadb-server mysql-server/root_password password secret" | debconf-set-selections
  echo "mariadb-server mysql-server/root_password_again password secret" | debconf-set-selections

  mkdir  /etc/mysql
  touch /etc/mysql/debian.cnf

  # Install MariaDB
  apt-get install -y mariadb-server mariadb-client

  # Configure Maria Remote Access and ignore db dirs
  sed -i "s/bind-address            = 127.0.0.1/bind-address            = 0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf
  cat > /etc/mysql/mariadb.conf.d/50-server.cnf << EOF
[mysqld]
bind-address = 0.0.0.0
ignore-db-dir = lost+found
#general_log
#general_log_file=/var/log/mysql/mariadb.log
EOF

  export MYSQL_PWD=secret

  mysql --user="root" -e "GRANT ALL ON *.* TO root@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
  service mysql restart

  mysql --user="root" -e "CREATE USER IF NOT EXISTS 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret';"
  mysql --user="root" -e "GRANT ALL ON *.* TO 'homestead'@'0.0.0.0' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
  mysql --user="root" -e "GRANT ALL ON *.* TO 'homestead'@'%' IDENTIFIED BY 'secret' WITH GRANT OPTION;"
  mysql --user="root" -e "FLUSH PRIVILEGES;"
  service mysql restart

  mysql_upgrade --user="root" --verbose --force
  service mysql restart

  unset MYSQL_PWD
fi

if "$SKIP_POSTGRESQL"; then
  echo "SKIP_POSTGRESQL is being used, so we're not installing PostgreSQL"
else
  # Install Postgres 14
  apt-get install -y postgresql-15 postgresql-server-dev-15 postgresql-15-postgis-3 postgresql-15-postgis-3-scripts

  # Configure Postgres Users
  sudo -u postgres psql -c "CREATE ROLE homestead LOGIN PASSWORD 'secret' SUPERUSER INHERIT NOCREATEDB NOCREATEROLE NOREPLICATION;"

  # Configure Postgres Remote Access
  sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" /etc/postgresql/15/main/postgresql.conf
  echo "host    all             all             10.0.2.2/32               md5" | tee -a /etc/postgresql/15/main/pg_hba.conf

  sudo -u postgres /usr/bin/createdb --echo --owner=homestead homestead
  service postgresql restart
  # Disable to lower initial overhead
  systemctl disable postgresql
fi

# Install Redis, Memcached, & Beanstalk
apt-get install -y redis-server memcached beanstalkd
systemctl enable redis-server
service redis-server start

# Configure Beanstalkd
sed -i "s/#START=yes/START=yes/" /etc/default/beanstalkd

# Install Golang
if [[ "$ARCH" == "aarch64" ]]; then
    GOLANG_LATEST_STABLE_VERSION=$(curl https://go.dev/dl/?mode=json | grep -o 'go.*.linux-arm64.tar.gz' | head -n 1 | tr -d '\r\n')
    wget https://dl.google.com/go/${GOLANG_LATEST_STABLE_VERSION} -O golang.tar.gz
else
    GOLANG_LATEST_STABLE_VERSION=$(curl https://go.dev/dl/?mode=json | grep -o 'go.*.linux-amd64.tar.gz' | head -n 1 | tr -d '\r\n')
    wget https://dl.google.com/go/${GOLANG_LATEST_STABLE_VERSION} -O golang.tar.gz
fi

tar -C /usr/local -xzf golang.tar.gz go
printf "\nPATH=\"/usr/local/go/bin:\$PATH\"\n" | tee -a /home/vagrant/.profile
rm -rf golang.tar.gz

# Install & Configure Mailpit
curl -sL https://raw.githubusercontent.com/axllent/mailpit/develop/install.sh | bash
chmod +x /usr/local/bin/mailpit
tee /etc/systemd/system/mailpit.service <<EOL
[Unit]
Description=Mailpit
After=network.target

[Service]
User=vagrant
StandardOutput=journal
StandardError=journal
ExecStart=/usr/bin/env /usr/local/bin/mailpit

[Install]
WantedBy=multi-user.target
EOL

systemctl daemon-reload
systemctl enable mailpit
service mailpit restart

# Configure Supervisor
systemctl enable supervisor.service
service supervisor start

# Install ngrok
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar xvzf ngrok-v3-stable-linux-amd64.tgz -C /usr/local/bin
rm -rf ngrok-v3-stable-linux-amd64.tgz

# Install & Configure Postfix
echo "postfix postfix/mailname string homestead.test" | debconf-set-selections
echo "postfix postfix/main_mailer_type string 'Internet Site'" | debconf-set-selections
apt-get install -y postfix
sed -i "s/relayhost =/relayhost = [localhost]:1025/g" /etc/postfix/main.cf
/etc/init.d/postfix reload

# Update / Override motd
echo "export ENABLED=1"| tee -a /etc/default/motd-news
sed -i "s/motd.ubuntu.com/homestead.joeferguson.me/g" /etc/update-motd.d/50-motd-news
sed -i "s/motd.ubuntu.com/homestead.joeferguson.me/g" /etc/default/motd-news
rm -rf /var/cache/motd-news
rm -rf /etc/update-motd.d/10-help-text
rm -rf /etc/update-motd.d/50-landscape-sysinfo
rm -rf /etc/update-motd.d/99-bento
service motd-news restart
bash /etc/update-motd.d/50-motd-news --force

# One last upgrade check
apt-get upgrade -y

# Clean Up
apt -y autoremove
apt -y clean
chown -R vagrant:vagrant /home/vagrant
chown -R vagrant:vagrant /usr/local/bin

# Perform some cleanup from chef/bento packer_templates/ubuntu/scripts/cleanup.sh
# Delete Linux source
dpkg --list \
    | awk '{ print $2 }' \
    | grep linux-source \
    | xargs apt-get -y purge;

# delete docs packages
dpkg --list \
    | awk '{ print $2 }' \
    | grep -- '-doc$' \
    | xargs apt-get -y purge;

# Delete obsolete networking
apt-get -y purge ppp pppconfig pppoeconf

# Configure chronyd to fix clock-drift when VM-host sleeps/hibernates.
sed -i "s/^makestep.*/makestep 1 -1/" /etc/chrony/chrony.conf

# Delete oddities
apt-get -y purge popularity-contest command-not-found friendly-recovery laptop-detect

# Exlude the files we don't need w/o uninstalling linux-firmware
echo "==> Setup dpkg excludes for linux-firmware"
cat <<_EOF_ | cat >> /etc/dpkg/dpkg.cfg.d/excludes
#BENTO-BEGIN
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
#BENTO-END
_EOF_

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove;
apt-get -y clean;

# Remove docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;

# Disable sleep https://github.com/laravel/homestead/issues/1624
systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target

# What are you doing Ubuntu?
# https://askubuntu.com/questions/1250974/user-root-cant-write-to-file-in-tmp-owned-by-someone-else-in-20-04-but-can-in
sysctl fs.protected_regular=0

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id

# Enable Swap Memory
/bin/dd if=/dev/zero of=/var/swap.1 bs=1M count=1024
/sbin/mkswap /var/swap.1
/sbin/swapon /var/swap.1
