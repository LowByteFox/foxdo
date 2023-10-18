# foxdo

minimal sudo in zig

# Building

```sh
git clone https://codeberg.org/LowByteFox/foxdo.git --recurse-submodules
cd foxdo
zig build
```
<br>

After that run `rootize.sh` as root and install

# Installation

As root run `cp -p ./zig-out/bin/foxdo /usr/local/sbin/` or just into `/usr/sbin`
Also don't forget to copy `defconfig` as `/etc/foxdo`
