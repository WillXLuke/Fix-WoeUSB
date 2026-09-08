# deb

The _deb_ distribution ships an architecture-independent Debian binary
package(`woeusb_<version>_all.deb`) that installs WoeUSB system-wide.

## Build

```sh
./dev-assets/build-deb.sh
```

Override the package version with the `WOEUSB_VERSION` environment
variable:

```sh
WOEUSB_VERSION=5.3.1 ./dev-assets/build-deb.sh
```

The resulting package is written to this directory.

## Install

```sh
sudo dpkg -i woeusb_<version>_all.deb
# Fix any missing dependencies if requested:
sudo apt-get install -f
```

After installation, the `woeusb` command is available from any console:

```sh
woeusb --help
```

## Uninstall

```sh
sudo dpkg -r woeusb
```
