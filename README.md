# Windows App Recognition and Installation Script

This script is designed to search for and recognize installed applications on a Windows system, and if available, attempt to install their corresponding packages using various package managers. The script utilizes a set of predefined data to map recognized applications to package names and is intended to simplify the process of managing software installations on Windows.

## Table of Contents

- [Introduction](#introduction)
- [Features](#features)
- [Requirements](#requirements)
- [Usage](#usage)
  - [Configuration](#configuration)
  - [Running the Script](#running-the-script)
- [Known Limitations](#known-limitations)
- [Contributing](#contributing)
- [License](#license)
- [Acknowledgments](#acknowledgments)

## Introduction

Managing software installations and package management on Windows systems can be a challenging task, especially when transitioning from one system to another or performing system maintenance. This script aims to automate the process of recognizing already installed applications and assisting in the installation of corresponding packages using package managers available on the system.

## Features

- **Application Recognition:** The script searches specified folders for executable files (.exe) and attempts to recognize them based on predefined data.
- **Package Mapping:** Recognized applications are mapped to their corresponding package names, which can be used for installation via package managers.
- **Package Manager Detection:** The script detects the appropriate package manager (apt, dnf, etc.) available on the system.
- **Package Availability Check:** The script checks whether the required package is available for installation using the detected package manager.
- **Interactive Installation:** If a recognized application's package is not available, the script interacts with the user to decide whether to install the application.
- **Batch Installation:** Supports an optional flag to install all recognized applications without user interaction.

## Requirements

- Python 3.x
- Administrative privileges (required for package installation)
- Supported package managers: apt, dnf (additional package managers can be added)

## Usage

### Configuration

1. Create the following configuration files in the same directory as the script:
   - `known_apps.txt`: This file should contain recognized application names and their corresponding readable names (key=value format). Example:
     ```
     notepad=Notepad
     chrome=Google Chrome
     ```
   - `package_mapping.txt`: This file should contain mappings between recognized application names and their corresponding package names (app_name:package_name format). Example:
     ```
     Notepad:notepad-plus-plus
     Google Chrome:google-chrome
     ```
2. Ensure the script has executable permissions (`chmod +x Script.py`).

### Running the Script

1. Open a terminal with administrative privileges.
2. Navigate to the directory containing the script.
3. Run the script using the following commands:
./Script.py [--install-all]

- `--install-all`: If provided, the script will attempt to install all recognized applications without user interaction.

4. Follow the script prompts and instructions displayed on the terminal.

## Known Limitations

- The script assumes certain folder structures on the Windows drive to identify user profiles and installed applications.
- The package availability check is limited to the package managers supported by the script.
- The package mappings and recognized application data must be accurate and up-to-date for the script to work effectively.
- The script might not cover all possible scenarios of software installations and package management.

## Contributing

Contributions to this project are welcome. If you encounter any issues, have ideas for improvements, or want to add support for additional package managers, please feel free to contribute by opening an issue or submitting a pull request.

## License

This project is licensed under the [MIT License](LICENSE).

## Acknowledgments

- This script was inspired by the need for simplified software installation and management on Windows systems.
- Special thanks to the open-source community and package maintainers for their contributions to package managers.
- Icons used in this README are from [Flaticon](https://www.flaticon.com/), licensed under [CC BY 3.0](http://creativecommons.org/licenses/by/3.0/).

