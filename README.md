# synk

**Synk** is a versatile command-line tool designed to simplify and streamline the process of synchronizing files between a local machine and connected Android devices and iOS simulators during mobile app development. With synk, developers can effortlessly observe changes in a specified local file hosted in their machine and instantly upload it to connected Android devices via `adb` or iOS simulators using `xcrun`.

## Installation

### Prerequisite

Before installing **synk**, make sure you have the following prerequisites:
- **Homebrew**: If you don't have Homebrew installed, you can install it by following the instructions at [https://brew.sh](https://brew.sh).
- **adb**
- **XCode**

### Install via Homebrew

Add new tap repository.

```bash
brew tap extmkv/brew
```

Install synk:

```bash
brew install synk
```

This will download and install the synk script on your system.

## Usage

### Basic Usage

To use **synk**, you can run it from the command line with the following syntax:

```bash
synk -f file [file path] -a [android packagename] -i [ios group id]
```

- `-f`: Specify the file to be observer and update on the devices.
- `-a`: Specify the packname of the Android app where you want to updated the file.
- `-i`: Specify the group of the iOS app where you want to updated the file.

### Examples

Observe and updates the file to the connected android devices with the specific app installed:

```bash
synk -f ~/example.json -a pt.jcosta.example.app
```

Observe and updates the file to the connected iOS simulators with the specific group available:
```bash
synk -f ~/example.json -i group.com.jcosta.example.app.content
```

Observe and updates for both, android and iOS:

```bash
synk -f ~/example.json -a pt.jcosta.example.app -i group.com.jcosta.example.app.content
```

### Help

You can view the help message by running:

```bash
synk -h
```

## License

```
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```


If you encounter any issues or have suggestions for improvement, please feel free to open an issue on this repository.

keep synking!