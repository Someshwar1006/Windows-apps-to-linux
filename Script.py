#!/usr/bin/env python3
import os
import subprocess
import sys


known_apps_file = "known_apps.txt"
recognized_apps_file = "recognized_apps.txt"
package_mapping_file = "package_mapping.txt"

known_apps = {}
package_map = {}

with open(known_apps_file, 'r') as f:
    for line in f:
        key, value = line.strip().split('=')
        known_apps[key] = value

with open(package_mapping_file, 'r') as f:
    for line in f:
        app_name, package_name = line.strip().split(':')
        package_map[app_name] = package_name

def search_apps(folder):
    app_list = []
    for root, dirs, files in os.walk(folder):
        for file in files:
            if file.lower().endswith(".exe") and os.access(os.path.join(root, file), os.X_OK):
                app_list.append(file)
    return app_list

def is_windows_drive(folder):
    return os.path.isdir(os.path.join(folder, "Windows")) and os.path.isdir(os.path.join(folder, "Users"))

def search_user_apps(folder):
    user_apps = []
    for root, dirs, files in os.walk(os.path.join(folder, "Users")):
        if "AppData" in dirs:
            user_apps.append(os.path.basename(root))
    return user_apps

def install_package(package_manager, package_name):
    if package_manager == "apt":
        subprocess.run(["sudo", "apt-get", "install", "-y", package_name])
    elif package_manager == "dnf":
        subprocess.run(["sudo", "dnf", "install", "-y", package_name])
    # Add more package managers and installation commands as needed
    else:
        print("Unknown package manager, cannot install", package_name)

def detect_package_manager():
    if os.path.isfile("/etc/os-release"):
        with open("/etc/os-release", 'r') as f:
            for line in f:
                if line.startswith("ID="):
                    distro_id = line.split('=')[1].strip().strip('"')
                    if distro_id in ["debian", "ubuntu"]:
                        return "apt"
                    elif distro_id in ["fedora", "centos", "rhel"]:
                        return "dnf"
    return "unknown"

def main():
    package_manager = detect_package_manager()
    if package_manager == "unknown":
        print("Unknown package manager.")
        exit(1)

    windows_drive = ""
    with open("/proc/mounts", 'r') as f:
        for line in f:
            drive = line.split()[1]
            if is_windows_drive(drive):
                windows_drive = drive
                break
    
    if not windows_drive:
        print("Windows drive not found or not mounted.")
        exit(1)
    
    print(f"Windows drive found: {windows_drive}")
    
    search_folders = [os.path.join(windows_drive, "Program Files"),
                      os.path.join(windows_drive, "Program Files (x86)"),
                      os.path.join(windows_drive, "Users")]
    
    recognized_apps = []
    
    for folder in search_folders:
        apps = search_apps(folder)
        if apps:
            print(f"Installed applications in {folder}:")
            for executable in apps:
                if executable in known_apps:
                    print(known_apps[executable])
                    recognized_apps.append(known_apps[executable])
                else:
                    print(f"{executable} (Unknown)")
            print()
    
    user_apps = search_user_apps(windows_drive)
    if user_apps:
        print("Installed applications in user profiles:")
        for app in user_apps:
            if app in known_apps:
                print(known_apps[app])
                recognized_apps.append(known_apps[app])
            else:
                print(f"{app} (Unknown)")
        print()
        with open(recognized_apps_file, 'w') as f:
            f.write("\n".join(recognized_apps))
        
        install_all = False
        if len(sys.argv) > 1 and sys.argv[1] == "--install-all":
            install_all = True
        
        for app_name in recognized_apps:
            if app_name in package_map:
                package_name = package_map[app_name]
                print(f"Checking {app_name} with package name {package_name}")

                found = False

                if package_manager == "apt":
                    result = subprocess.run(["apt", "list", "--installed", package_name], capture_output=True, text=True)
                    if f"{package_name}/" in result.stdout:
                        print(f"{app_name} is already installed via APT")
                        found = True
                elif package_manager == "dnf":
                    result = subprocess.run(["dnf", "list", "installed", package_name], capture_output=True, text=True)
                    if f"{package_name}." in result.stdout:
                        print(f"{app_name} is already installed via DNF")
                        found = True
                # Add more package managers and availability checks here

                if not found:
                    print(f"{app_name} is not available in any known repository")
                    if install_all:
                        install_package(package_manager, package_name)
                    else:
                        choice = input(f"Do you want to install {app_name}? (y/n): ").lower()
                        if choice.startswith('y'):
                            install_package(package_manager, package_name)
            else:
                print(f"No package mapping found for {app_name}")

if __name__ == "__main__":
    main()
