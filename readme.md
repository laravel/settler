# A Windows Subsystem for Linux PHP Development Environment Setup

This scripts is a minor modification to the script that uses the Laravel Homestead development environment configurations.

This will provide you with a wonderful development environment without requiring you to install manually install PHP, a web server, and any other server software on your local machine. No more worrying about messing up your operating system! Includes the Nginx web server, PHP 7.2, MySQL, Postgres, Redis, Memcached, Node, and all of the other goodies you need to develop in PHP or via the Drupal, Laravel, or Wordpress Frameworks.

## Environment Overview

This environment was intended for Laravel Development, but includes other tools as well.
* Coding Languages:
  * Golang
  * PHP: (each of the following)
    * _7.2_
    * _7.1_
    * _7.0_
    * _5.6_  
* PHP Framework Support:
  * Drupal - (drush command line tool)
  * Laravel - (installers for Laravel, Lumen, Envoy, and Spark, plus support for Laravel Dusk)
  * Wordpress - (via wp-cli)
* Database/Cache Services:
  * MySQL
  * PostgreSQL
  * Redis
  * Memcached
  * SQLite
  * Beanstalkd
* Nodejs Build Tools:
  * Nodejs
  * npm
  * gulp-cli
  * bower
  * yarn
  * grunt-cli
* Debugging/Profiling Tools:
 * Xdebug (automatically disabled for the command line)
 * Blackfire
 * Zend Z-Ray
 
## Usage

Download the provision script:

`` wget "https://raw.githubusercontent.com/elegasoft/settler/master/scripts/provision.sh" >> provision.sh ``

Confirm it has been downloaded  (``ls -l``) and rename it if necessary `` mv provision.sh.1 provision.sh ``.

Allow the provision script to be executable:

``chmod x+ provision.sh``

Run the installer:

``sudo bash provision.sh``

Unfortunately in my experience the installation is quite slow and may take an hour to complete.
