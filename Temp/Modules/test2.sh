#!/bin/bash

echo $1

argAry1=("${!1}")

# declare -a argAry1=( ${1} )
for i in "${argAry1[@]}"
do
   echo "Element: ${i}"
done
