#!/bin/bash

SCRIPT_DIR=$(cd -P -- "$(dirname -- "$0")" && pwd -P)
HOME_DIR=$(awk -v FS=':' -v user="$USER" '($1==user) {print $6}' "/etc/passwd")

INSTALL=false
REMOVE=false
FORCE=false
PROJECT=""
SOURCE="$HOME_DIR/resources"

function usage() {
    echo "Usage: resources [OPTION]"
    echo "Options:"
    echo "  --install"
    echo "  --remove"
    echo "  --force"
    echo "  --project [PROJECT]"
    echo "  --source [SOURCE]"
    exit 0
}

while [ "$#" -gt 0 ]
do
    case "$1" in
      --install)
          INSTALL=true
          ;;
      --remove)
          REMOVE=true
          ;;
      --force)
          FORCE=true
          ;;
      --project)
          shift
          if [ -n "$1" ]; then
              PROJECT=$1
          fi
          ;;
      --source)
          shift
          if [ -n "$1" ]; then
              SOURCE=$1
          fi
          ;;
      --help)
          usage
          ;;
      --)
          shift
          break;;
      *)
          echo "resources: invalid option $1"
          usage
          ;;
    esac
    shift
done

# read all 'readme.txt' files in resources directory
# reference: http://stackoverflow.com/questions/8213328/bash-script-find-output-to-array
file_list=()
while IFS= read -d $'\0' -r file ; do
    file_list=("${file_list[@]}" "$file")
done < <(find $SCRIPT_DIR -iregex ".*/resources/readme\.txt" -print0)

for file in "${file_list[@]}" ; do
    RESOURCES_DIR=$(dirname $file)
    # filter on project
    if [ ! "X$PROJECT" = "X" ]; then
        PROJECT_NAME="$(basename ${RESOURCES_DIR%/*/*})"
        [[ ! "$PROJECT" = "$PROJECT_NAME" ]] && continue
    fi
    # if force=true, remove all files except readme.txt and .gitignore
    if [ "$FORCE" = "true" ]; then
        find $RESOURCES_DIR -type f -regextype posix-extended ! -iregex ".*/(readme\.txt|\.gitignore)" -print0 | xargs -0 rm
    fi
    # read each line of the readme.txt, ignore comments
    while IFS='' read -r line || [[ -n "$line" ]]; do
        [[ "$line" =~ ^#.*$ ]] && continue
        if [ "$REMOVE" = "true" ]; then
            echo "removing $RESOURCES_DIR/$line" 
            rm -f $RESOURCES_DIR/$line        
        fi
        if [ "$INSTALL" = "true" ]; then
            echo "copying $SOURCE/$line to $RESOURCES_DIR"
            cp -p $SOURCE/$line $RESOURCES_DIR
        fi       
    done < "$file"
done
