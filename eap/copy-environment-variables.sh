#! /bin/bash

if [ -f /environment ];
then
  rm -f /environment
fi

env | grep _ >> /environment
exit 0
