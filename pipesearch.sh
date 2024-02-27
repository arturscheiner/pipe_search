#!/bin/bash

# Declare the search term as the first command-line argument
SEARCH=$1

# Check if the search term is provided
if [ -z "$SEARCH" ]; then
    echo "Error: Please provide a search term."
    echo "Usage: ./pipeline_search.sh <search_term>"
    exit 1  # Optional: Exit with an error code
fi

# Remove any existing temporary file named 'pipelist'
rm -f pipelist

# Get the total number of pipeline pages from DigiBee
PAGES=$(digibeectl get pipelines | tail -n1 | awk '{print $NF}')

# Iterate through each pipeline page
for l in $(seq 1 $PAGES)
do
    echo "Creating pipeline list based on page $l"

    # Get the pipeline listing for the current page, remove extra lines, and append to 'pipelist'
    digibeectl get pipelines --page $l | tail -n +2 | sed -e '$ d' | sed -e '$ d' >> pipelist
done

echo "--------------------------------------------"
echo
echo "Pipelines that have the: $SEARCH"
echo

# Specify the file to read pipeline entries from
FILE="pipelist"

# Iterate through each line in the 'pipelist' file
while IFS= read -r line; do
    # Extract pipeline name, ID, and version from the line
    PIPENAME=$(echo $line  | awk '{print $1}')
    PIPEID=$(echo $line  | awk '{print $2}')
    PIPEVERSION=$(echo $line | awk '{print $3}')

    # Retrieve the pipeline flowspec using its ID and search for the specified term
    FIND=$(digibeectl get pipeline --pipeline-id $PIPEID --flowspec | grep "$SEARCH")

    # If the search term is found, display the pipeline's name and version 
    if [ -n "$FIND" ]; then
        echo "$PIPENAME - $PIPEVERSION"
    fi
done < "$FILE" 