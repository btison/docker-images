#! /bin/bash

#
# Script arguments
#  -f, --force : defaults to false
#  --remove : defaults to false

# Resources
SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
SOURCE_RESOURCES_DIR=$HOME/resources

TARGET_RESOURCES_DIR=$SCRIPT_DIR/resources

RESOURCES=( jboss-bpmsuite-6.1.0.ER6-deployable-eap6.x.zip jboss-as-dist-7.5.0.Final-redhat-18.zip )

# Force flag
FORCE=FALSE

# Clean flag
REMOVE=FALSE

#
# Usage
#
function usage
{
    echo "usage: $0 [-f] [--remove]"
}

#
# Clean
#
function remove
{
    if [ -f $1 ];
    then
        rm -f $1
    fi 
}

#
# Copy
#
function copy
{
    RESOURCE=$(basename $1)
    if [ ! -f $2/$RESOURCE ] || [ "$FORCE" == "true" ];
    then
        cp -f --preserve=all $1 $2
    fi 
}

#
# Parse command line options 
#
while [ "$1" != "" ]; do
    case $1 in
        --remove )              REMOVE=true
                                ;;
        -f | --force )          FORCE=true
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

#
# Remove if necessary
#
if [ "$REMOVE" = "true" ];
then
    for i in "${RESOURCES[@]}"
    do
        remove $TARGET_RESOURCES_DIR/${i}
    done
fi

#
# Copy resources
#
if [ ! "$REMOVE" = "true" ];
then
    for i in "${RESOURCES[@]}"
    do
        copy $SOURCE_RESOURCES_DIR/${i} $TARGET_RESOURCES_DIR 
    done
fi

