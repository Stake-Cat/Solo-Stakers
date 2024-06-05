# Get all associated Validator keys from deposit addresses.
# Using Beaconcha.in Api, possible to use a local beacon node as alternative.
# Requires input_file as a list of addresses to query. 

#!/bin/bash

# File containing the list of Ethereum addresses
input_file="solo-staker-a"

# Output file for the results
output_csv="output.csv"
echo "address,publickey" > "$output_csv"

# Your API key
api_key="<API-KEY-HERE>"

# Check if the input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file does not exist."
    exit 1
fi

# Read each address from the file and process it
while IFS= read -r address; do
    if [[ -n "$address" ]]; then  # Ensure the line is not empty
        # Fetch data using curl with API key
        data=$(curl -s -X 'GET' \
          "https://beaconcha.in/api/v1/validator/eth1/$address" \
          -H 'accept: application/json' \
          -H "apikey: $api_key")

        # Check if the request was successful and data is not empty
        if [[ $(echo $data | jq '.status') == "\"OK\"" && $(echo $data | jq '.data | length') -gt 0 ]]; then
            # Extract public keys and append to CSV file
            echo $data | jq -r --arg address "$address" '.data[] | [$address, .publickey] | @csv' >> "$output_csv"
        else
            echo "No data found or error fetching data for address $address."
        fi
    fi
done < "$input_file"

echo "CSV file has been updated with public keys."