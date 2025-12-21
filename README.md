# Ubuilt

**Ubuilt** *(Ubuntu + built)* is a tool for creating Ubuntu-based Live CDs.

It uses **rsync** to copy your root filesystem, **mksquashfs** to create a compressed filesystem, and **grub-mkrescue** to create a bootable ISO image. If you used chroot mode, you will be dropped into a shell to customize the filesystem before creating the squashfs.

**Ubuilt** uses `zenity` to create a simple and user-friendly graphical interface for managing the process.

## How to use Ubuilt

### 1. Cloning the repository
Use `git` to clone the repository first (install `git` first if you haven't):
```bash
git clone https://github.com/tekidev0/ubuilt2.git Ubuilt/ && cd Ubuilt/
```

### 2. Install required packages
Install the required packages before the process:
```bash
sudo apt update && sudo apt install rsync squashfs-tools mtools grub-pc-bin xorriso zenity
```

### 3. Run Ubuilt
Run Ubuilt:
```bash
./ubuilt.sh
```
This will bring up `zenity` (the GUI) to guide you through the process. It will also ask for your password to run root operations with `pkexec`.

### 4. Customizing GRUB (optional)
It's optional if you want to keep the Ubuilt branding, but recommended if you are creating a custom distribution.

#### 4.1. Editing the bootloader configuration (`grub.cfg`)
The `grub.cfg` file is where it controls the text and boot paramaters. You can edit it (if you're changing the menu entries or something):
```bash
nano ISOFiles/boot/grub/grub.cfg
```

#### 4.2. Replace the background (`bootlogo.png`)
The `bootlogo.png` file is the background used in the `grub.cfg` file. The default `bootlogo.png` is a **Ubuilt-branded image** and is **800x600**. You can also replace it:
```bash
cp /path/to/your/image.png ISOFiles/boot/grub/bootlogo.png
```
Replace `/path/to/your/image.png` with your actual image.

- Tip: for the best results, the image needs to be **800x600** or **640x480**.

## Versions

### Ubuilt2.x

| Version | Date       | Note |
|---------|------------|------|
| Ubuilt2.0 | 2025-12-25 | Initial release |
| Ubuilt2.1 | TBD        | Upcoming features |
