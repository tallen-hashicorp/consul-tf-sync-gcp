#!/bin/bash

# Check if the GCP_PROJECT_ID environment variable is set
if [ -z "$GCP_PROJECT_ID" ]; then
    echo "Error: The GCP_PROJECT_ID environment variable is not set."
    exit 1
fi

# Print GCP_PROJECT_ID
echo "GCP_PROJECT_ID: $GCP_PROJECT_ID"

# Define the configuration file path
CONFIG_FILE="/tmp/consul.hcl"

# Use sed to replace the gcp_project_id line with the new project ID
sed -i 's/gcp_project_id = ""/gcp_project_id = "'"$GCP_PROJECT_ID"'"/' $CONFIG_FILE 

# Inform the user that the replacement is done
echo "Updated gcp_project_id in $CONFIG_FILE to $GCP_PROJECT_ID"
