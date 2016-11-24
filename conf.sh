#!/usr/bin/env bash

DOCKERVOL_ROOT='/docker_volumes'

# configure container
export IMGID='25'  # range from 02 .. 99; must be unique
PROJSHORT='drupal'

export IMAGENAME="r2h2/drupal"
export CONTAINERNAME="${IMGID}$PROJSHORT"
export CONTAINERUSER="$PROJSHORT${IMGID}"   # group and user to run container
export CONTAINERUID="33"     # synonymous with www-data
export ENVSETTINGS=""

export NETWORKSETTINGS="
    --net http_proxy
    --ip 10.1.1.${IMGID}
    --add-host=mariadb:10.1.1.24
    --add-host=sp4.test.portalverbund.gv.at/:10.1.1.25
    -p 8088:80
"
export VOLROOT="${DOCKERVOL_ROOT}/$CONTAINERNAME"  # container volumes on docker host
export VOLMAPPING="
    -v $VOLROOT/apache2/servername.conf:/etc/apache2/conf-enabled/servername.conf:ro
    -v $VOLROOT/drupal/settings.php:/var/www/html/sites/default/settings.php:Z
"

export STARTCMD=''
export START_AS_ROOT='True'      # start as root (e.g. for apache to fall back to www user)

# first start: create user/group/host directories
if [ $(id -u) -ne 0 ]; then
    sudo="sudo"
fi
if ! id -u $CONTAINERUSER &>/dev/null; then
    if [[ ${OSTYPE//[0-9.]/} == 'darwin' ]]; then
            $sudo sudo dseditgroup -o create -i $CONTAINERUID $CONTAINERUSER
            $sudo dscl . create /Users/$CONTAINERUSER UniqueID $CONTAINERUID
            $sudo dscl . create /Users/$CONTAINERUSER PrimaryGroupID $CONTAINERUID
    else
      source /etc/os-release
      case $ID in
        centos|fedora|rhel)
            $sudo groupadd --non-unique -g $CONTAINERUID $CONTAINERUSER
            $sudo adduser --non-unique -M --gid $CONTAINERUID --comment "" --uid $CONTAINERUID $CONTAINERUSER
            ;;
        debian|ubuntu)
            $sudo groupadd -g $CONTAINERUID $CONTAINERUSER
            $sudo adduser --gid $CONTAINERUID --no-create-home --disabled-password --gecos "" --uid $CONTAINERUID $CONTAINERUSER
            ;;
        *)
            echo "do not know how to add user/group for OS ${OSTYPE} ${NAME}"
            ;;
      esac
    fi
fi

function chkdir {
    dir=$1; user=$2
    $sudo mkdir -p "$VOLROOT/$dir"
    $sudo chown -R $user:$user "$VOLROOT/$dir"
}

# create if not existing and set owner for path on docker host relative to $VOLROOT
chkdir drupal $CONTAINERUSER
touch $VOLROOT/drupal/settings.php
chkdir apache2 $CONTAINERUSER
touch $VOLROOT/apache2/servername.conf
