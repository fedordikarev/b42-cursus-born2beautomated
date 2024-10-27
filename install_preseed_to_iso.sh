#!/bin/bash

### Run this script inside Docker contaier

out_folder="/output"
preseed_cfg="/preseed.cfg"

mkdir -p "${out_folder}/preseed"
cp ${preseed_cfg} "${out_folder}/preseed/"

chmod u+w "${out_folder}/isolinux/txt.cfg"
cat <<EOF | tee -a "${out_folder}/isolinux/txt.cfg"

default auto
label auto
	menu label a^Utomated Install
	kernel /install.amd/vmlinuz
	append initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed/preseed.cfg language=en country=DE locale=en_US.UTF-8 keymap=us
EOF

sed -i.bak -e 's/default installgui/default auto/' "${out_folder}/isolinux/gtk.cfg"
