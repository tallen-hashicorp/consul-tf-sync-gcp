#!/bin/bash

# Prompt user for input
echo "Please enter your GCP Project ID:"
read gcp_project_id

# Default region to London
gcp_region="europe-west2"

# Default zone to London
gcp_zone="europe-west2-a"

# Default value for image_family
image_family="almalinux-8"

# Create or overwrite the .pkrvars.hcl file with the provided values
cat <<EOF > variables.pkrvars.hcl
gcp_project_id = "${gcp_project_id}"
gcp_region     = "${gcp_region}"
gcp_zone       = "${gcp_zone}"
image_family   = "${image_family}"
EOF

# Print success message
echo "Variables saved to variables.pkrvars.hcl:"
cat variables.pkrvars.hcl
