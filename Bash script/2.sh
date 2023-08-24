#!/bin/bash

# Read the input file containing the list of applications
input_file="recognized_apps.txt"

# Read the package mapping from the separate file
declare -A package_map
while IFS=':' read -r app_name package_name; do
    package_map["$app_name"]="$package_name"
done < "package_mapping.txt"

# Detect the Linux distribution
if [ -f "/etc/os-release" ]; then
    . /etc/os-release
    if [ "$ID" == "debian" ] || [ "$ID" == "ubuntu" ]; then
        package_manager="apt"
    elif [ "$ID" == "fedora" ] || [ "$ID" == "centos" ] || [ "$ID" == "rhel" ]; then
        package_manager="dnf"
    else
        package_manager="unknown"
    fi
else
    package_manager="unknown"
fi

# Check if the master install-all option is set
install_all=false
if [[ "$1" == "--install-all" ]]; then
    install_all=true
fi

# Loop through each line in the input file
while IFS= read -r app_name; do
    if [[ -n "${package_map[$app_name]}" ]]; then
        package_name="${package_map[$app_name]}"
        echo "Checking $app_name with package name $package_name"
        
        found=false
        
        case "$package_manager" in
            "apt")
                # Check if the application is available in APT (Debian/Ubuntu)
                if apt list --installed "$package_name" 2>/dev/null | grep -q "$package_name"; then
                    echo "$app_name is available in APT"
                    found=true
                fi
                ;;
            "dnf")
                # Check if the application is available in DNF (Fedora, CentOS, RHEL)
                if dnf list installed "$package_name" 2>/dev/null | grep -q "$package_name"; then
                    echo "$app_name is available in DNF"
                    found=true
                fi
                ;;
            # Add more package managers and repositories here
            
            *)
                echo "Unknown package manager for $app_name"
                ;;
        esac
        
        if ! "$found"; then
            echo "$app_name is not available in any known repository"
            if $install_all; then
                case "$package_manager" in
                    "apt")
                        sudo apt-get install -y "$package_name"
                        ;;
                    "dnf")
                        sudo dnf install -y "$package_name"
                        ;;
                    # Add more package managers and installation commands as needed
                    *)
                        echo "Unknown package manager, cannot install $app_name"
                        ;;
                esac
            else
                read -rp "Do you want to install $app_name? (y/n): " choice
                if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
                    case "$package_manager" in
                        "apt")
                            sudo apt-get install -y "$package_name"
                            ;;
                        "dnf")
                            sudo dnf install -y "$package_name"
                            ;;
                        # Add more package managers and installation commands as needed
                        *)
                            echo "Unknown package manager, cannot install $app_name"
                            ;;
                    esac
                fi
            fi
        fi
    else
        echo "No package mapping found for $app_name"
    fi
done < "$input_file"

