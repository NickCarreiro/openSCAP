# Ubuntu 22.04 STIG Remediation System

This system supports scanning and remediation of Ubuntu 22.04 using:
- SCAP Security Guide (SSG) community content
- Official DISA STIG SCAP benchmark

## Usage

```bash
cd openSCAP/

# Make *.sh scripts executable
find . -type f -name "*.sh" -exec chmod +x {} \;

# Download and scan with SSG
bash ssg/fetch_ssg.sh
bash ssg/scan_ssg.sh
bash ssg/generate_remediation.sh
bash remediation/ssg_remediation_<timestamp>.sh  # apply fixes

# Download and evaluate DISA STIG
bash disa/fetch_disa_stig.sh
bash disa/scan_disa_stig.sh

# Run additional scripts as needed
bash disa/testing/<script_name>.sh
