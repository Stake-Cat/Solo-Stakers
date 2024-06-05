# Using validator keys from step one as an 'input_file'
# Obtain withdrawal information for each validator key
#


#!/bin/bash

# File containing the list of public keys
input_file="validator-keys"

# Output file for the results
output_csv="output.csv"
echo "validator-key,status,exitepoch" > "$output_csv"

# Your API key
api_key="<API-KEY-HERE>"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file does not exist."
    exit 1
fi

# Read each public key from the file and process it
while IFS= read -r public_key; do
    if [[ -n "$public_key" ]]; then  # Ensure the line is not empty
        # Fetch data using curl with API key
        data=$(curl -s -X 'GET' \
          "https://beaconcha.in/api/v1/validator/$public_key" \
          -H 'accept: application/json' \
          -H "apikey: $api_key")

        # Check if the request was successful and data is not empty
        if [[ $(echo $data | jq '.status') == "\"OK\"" && $(echo $data | jq '.data') != null ]]; then
            # Extract needed fields and append to CSV file
            echo $data | jq -r --arg public_key "$public_key" '.data | [$public_key, .status, .exitepoch] | @csv' >> "$output_csv"
        else
            echo "No data found or error fetching data for public key $public_key."
        fi
    fi
done < "$input_file"

echo "CSV file has been updated with the requested details."