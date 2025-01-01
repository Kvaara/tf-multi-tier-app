# Still Not There Yet...

This should've been a super-quick Terraform project to showcase its power on OCI instead of AWS and test my skills, but all this project did was show me how incompetent I still am... This was more like "super-slow" because 3 hours turned into 2 days.

## How To Deploy

1. Install Terraform on your workstation.
2. Sign up for an Oracle Cloud Infrastructure tenant (*if not already*), generate an API key from your profile and use it to configure the OCI Terraform Provider.
3. Download or clone the repository.
4. Find out what your OCI tenancy's OCID is (*the root compartment OCID*) and paste it to the `tenancy_ocid` variable located inside the variable template file `terraform.tfvars`.
5. Run `terraform init` and `terraform apply` in the cloned/downloaded project's root directory.
6. After provisioning is done, the terminal should output you the URL link where the web application is available.
