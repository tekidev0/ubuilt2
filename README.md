# Ubuilt

**Ubuilt** *(Ubuntu + built)* is a tool for creating Ubuntu-based Live CDs.

It uses **rsync** to copy your root filesystem, **mksquashfs** to create a compressed filesystem, and **grub-mkrescue** to create a bootable ISO image. If you used chroot mode, you will be dropped into a shell to customize the filesystem before creating the squashfs.

**Ubuilt** uses `zenity` to create a simple and user-friendly graphical interface for managing the process. It also uses `dialog` for the CLI interface.

## How to use Ubuilt

### 1. Cloning the repository
Use `git` to clone the repository first (install `git` first if you haven't):
```bash
git clone https://github.com/tekidev0/ubuilt2.git Ubuilt/ && cd Ubuilt/
```

### 2. Install required packages
Install the required packages before the process:
```bash
sudo apt update && sudo apt install rsync squashfs-tools mtools grub-pc-bin xorriso zenity dialog
```

### 3. Remove the placeholder file from Overlay directory
Remove the placeholder file `removeme.txt` from the `Overlay` directory before running Ubuilt.
```bash
rm Overlay/removeme.txt
```

### 4. Run Ubuilt
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
| Ubuilt2.0.2 Preview | 2.0.2-preview | 2026-01-15 | Apply overlay bug fix |
| Ubuilt2.1 Beta | 2.1-beta | 2026-01-01 | CLI support (`--cli` flag), and more |
| Ubuilt2.1 | 2.1 | 2026-02-02 | Upcoming features |
