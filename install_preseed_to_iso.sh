#!/bin/bash

### Run this script inside Docker contaier

out_folder="/output"
preseed_cfg="/preseed.cfg"

menu_cfg="${out_folder}/isolinux/menu.cfg"

mkdir -p "${out_folder}/preseed"
cp ${preseed_cfg} "${out_folder}/preseed/"

chmod u+w "${out_folder}/isolinux/txt.cfg"
cat <<EOF | tee -a "${out_folder}/isolinux/txt.cfg"
default auto
autoselect auto
label auto
	menu default
	menu label a^Utomated Install
	kernel /install.amd/vmlinuz
	append initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed/preseed.cfg language=en country=DE locale=en_US.UTF-8 keymap=us
EOF

chmod +w "${menu_cfg}"
sed -i -e '/include gtk.cfg/d' -e '/include spkgtk.cfg/d' -e '/include spk.cfg/d' "${menu_cfg}"
chmod -w "${menu_cfg}"
