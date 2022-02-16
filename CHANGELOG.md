# Changelog

All notable changes to this project will be documented in this file.

## Release 0.3.8

**Features**

- Zip archives will now be extracted into paths following the convention: {resource path}/{archive name}

## Release 0.3.3

**Features**

- On Windows, added logic to wait for file lock availability after downloading and/or unzipping Blobs

## Release 0.3.2

**Bugfixes**

- azcopy Windows download method
- Fix escaped paths in unzip


## Release 0.3.0

**Features**

- Improvements to unzip for Windows OS
- Moved azcopy and unzip functionality into classes

## Release 0.2.0

**Features**

- Added support for azcopy as transfer utility

## Release 0.1.9

**Features**

- File resource permissions now default to 'undef'

## Release 0.1.6

**Features**

- Handle spaces in filesystem paths

## Release 0.1.5

**Features**

- 'creates' parameter will now purge the original zip file after extraction

**Bugfixes**

- Documentation updates

## Release 0.1.4

**Bugfixes**

- Documentation clarity and updates

## Release 0.1.3

**Bugfixes**

- Fixed an issue with type definition

## Release 0.1.2

**Bugfixes**

- Address typos in documentation

## Release 0.1.1

**Features**
1. File mode/permisions management is now handled by native Puppet File class
1. Added unzip capability with 'creates' parameter

## Release 0.1.0

**Features**

- Initial release
