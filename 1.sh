#!/bin/bash

known_apps_file="known_apps.txt"
recognized_apps_file="recognized_apps.txt"

declare -A known_apps

while IFS='=' read -r key value; do
    known_apps["$key"]="$value"
done < "$known_apps_file"

# Function to search for installed applications in a folder
search_apps() {
    local folder="$1"
    local app_list=()
    while IFS= read -r -d '' file; do
        if [[ -f "$file" && -x "$file" ]]; then
            app_list+=("${file##*/}")
        fi
    done < <(find "$folder" -type f -iname "*.exe" -print0)
    echo "${app_list[@]}"
}

# Function to check if a folder contains Windows specific subfolders
is_windows_drive() {
    local folder="$1"
    if [[ -d "$folder/Windows" && -d "$folder/Users" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to search for installed applications in user profile folders
search_user_apps() {
    local folder="$1"
    local user_apps=()
    while IFS= read -r -d '' user_folder; do
        if [[ "$user_folder" =~ /AppData/(Local|LocalLow|Roaming)$ ]]; then
            user_apps+=("$(basename "$user_folder")")
        fi
    done < <(find "$folder/Users" -maxdepth 3 -type d -name "AppData" -print0)
    echo "${user_apps[@]}"
}

# Function to install recognized applications
install_apps() {
    local script_path="$1"
    for app_name in $(cat "$recognized_apps_file"); do
        echo "Installing $app_name..."
        chmod +x "$script_path"
        sudo "$script_path" --install-all
    done
}

# Ask the user if they want to install recognized applications
ask_installation() {
    read -p "Do you want to install the recognized applications? (yes/no): " choice
    case $choice in
        [Yy]* ) install_apps "./2.sh";;
        [Nn]* ) echo "Installation skipped.";;
        * ) echo "Invalid choice. Installation skipped.";;
    esac
}

# Main function to scan all drives and search for Windows installation
main() {
    local windows_drive=""
    while IFS= read -r line; do
        local drive="/media/someshwar/Windows"  # Update this with the correct path to the Windows drive
        if is_windows_drive "$drive"; then
            windows_drive="$drive"
            break
        fi
    done < "/proc/mounts"

    if [[ -z "$windows_drive" ]]; then
        echo "Windows drive not found or not mounted."
        exit 1
    fi

    echo "Windows drive found: $windows_drive"

    local search_folders=("$windows_drive/Program Files" "$windows_drive/Program Files (x86)" "$windows_drive/Users")

    for folder in "${search_folders[@]}"; do
        apps=($(search_apps "$folder"))
        if [[ ${#apps[@]} -gt 0 ]]; then
            echo "Installed applications in $folder:"
            for executable in "${apps[@]}"; do
                if [[ -n ${known_apps[$executable]} ]]; then
                    echo "${known_apps[$executable]}"
                    echo "${known_apps[$executable]}" >> "$recognized_apps_file"
                else
                    echo "$executable (Unknown)"
                fi
            done
            echo
        fi
    done

    user_apps=($(search_user_apps "$windows_drive"))
    if [[ ${#user_apps[@]} -gt 0 ]]; then
        echo "Installed applications in user profiles:"
        for app in "${user_apps[@]}"; do
            if [[ -n ${known_apps[$app]} ]]; then
                echo "${known_apps[$app]}"
                echo "${known_apps[$app]}" >> "$recognized_apps_file"
            else
                echo "$app (Unknown)"
            fi
        done
        echo
        ask_installation
    fi
}

main

