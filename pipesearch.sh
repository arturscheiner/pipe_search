#!/bin/bash

SEARCH=$1

rm -f pipelist

PAGES=$(digibeectl get pipelines | tail -n1 | awk '{print $NF}')

for l in $(seq 1 $PAGES)
do
    echo "Creating pipeline list based on page $l"
    digibeectl get pipelines --page $l | tail -n +2 | sed -e '$ d' | sed -e '$ d' >> pipelist
done

echo "--------------------------------------------"
echo
echo "Pipelines that have the: $SEARCH"
echo

FILE="pipelist"
while IFS= read -r line; do
    PIPENAME=$(echo $line  | awk '{print $1}')
    PIPEID=$(echo $line  | awk '{print $2}')
    PIPEVERSION=$(echo $line | awk '{print $3}')
    FIND=$(digibeectl get pipeline --pipeline-id $PIPEID --flowspec | grep "$SEARCH")
    if [ -n "$FIND" ]; then
        echo "$PIPENAME - $PIPEVERSION"
    fi
done < "$FILE" 