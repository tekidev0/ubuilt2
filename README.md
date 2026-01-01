# Ubuilt

> NOTE: Ubuilt will turn into URemaster with the 2.1 release.

**Ubuilt** *(Ubuntu + built)* is a tool for creating Ubuntu-based Live CDs.

## How to use Ubuilt

### 1. Cloning the repository
Use `git` to clone the repository first (install `git` first if you haven't):
```bash
git clone https://github.com/tekidev0/ubuilt2.git Ubuilt/ && cd Ubuilt/
```

### 2. Install required packages
Install the required packages before the process:
```bash
sudo apt update && sudo apt install rsync casper squashfs-tools mtools grub-pc-bin xorriso zenity dialog
```
You can also install `jq` for JSON processing:
```bash
sudo apt install jq
```
If you want to support Secure Boot for the ISO, install these packages:
```bash
sudo apt install mokutil sbsigntool openssl
```
### 3. Run Ubuilt
Run Ubuilt:
```bash
./ubuilt.sh
```
Or the CLI version:
```
./ubuilt.sh --cli
```
## Versions

### Ubuilt2.x

| Version | Tag | Date       | Note |
|---------|-----|------------|------|
| Ubuilt2.0 | 2.0 | 2025-12-23 | Initial release |
| Ubuilt2.0.1 Preview | 2.0.1-preview | 2025-12-27 | Some features from Ubuilt2.1 Beta including CLI support |
| Ubuilt2.1 Beta | 2.1-beta | 2026-01-01 | CLI support (`--cli` flag), and more |

### URemaster 2.x

| Version | Tag | Date       | Note |
|---------|-----|------------|------|
| URemaster 2.1 | 2.1 | 2026-02-02 | Upcoming features |
