# owncloud-pi

This is a docker container of [owncloud](https://owncloud.org/) that runs on the [RaspberryPi](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/).

## Features

* Owncloud runs in a container based on Arch Linux
* Setup as proposed in the [Arch Wiki] (https://wiki.archlinux.org/index.php/OwnCloud):
	* `php-intl` and `php-mcrypt` extensions enabled
	* `OPCache + APCu` enabled
	* Access to `/dev/urandom` enabled
	* Database support-ready (SQLite and PostgreSQL)
	* `exif` support
* Generates a temporary, default SSL Key and Cert

## Installation

1. Install docker from the package repository: 

`sudo pacman -S docker`

2. Pull the owncloud-pi: 

`sudo docker pull astonbitecode/owncloud-pi`

3. Run it in docker: 

`sudo docker run -d --name oc -p 80:80 -p 443:443 -t astonbitecode/owncloud-pi`

4. Setup your owncloud, by browsing to

_http://localhost/owncloud_

or 

_https://localhost/owncloud_

## Build

Building from the sources offers a more up-to-date installation.

In order to build, simply clone this repo and  issue:

`sudo docker build -t your_username/owncloud-pi:latest .`

or simply

`sudo docker build .`
