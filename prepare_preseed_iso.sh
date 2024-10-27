#!/bin/bash

# [ -d /mnt/debian-iso ] || sudo mkdir /mnt/debian-iso
# sudo mount -o loop ~/iso/debian-12.6.0-amd64-netinst.iso /mnt/debian-iso


# export LD_LIBRARY_PATH=$HOME/.local/usr/lib/x86_64-linux-gnu/
# export PATH=$PATH:$HOME/.local/usr/bin

if [ -d "/goinfre" ]; then
	src_folder="/media/$USER/Debian 12.6.0 amd64 n"
	tmp_folder="/goinfre/$USER/temp-iso"
	iso_fname="/goinfre/$USER/debian-preseed.iso"
else
	src_folder="$HOME/iso"
	src_iso="$HOME/iso/debian-12.5.0-arm64-netinst.iso"
	tmp_folder="$HOME/iso/temp-iso"
	iso_fname="$HOME/iso/debian-preseed.iso"
fi

src_iso="$HOME/iso/debian-12.6.0-amd64-netinst.iso"
tmp_folder="$HOME/goinfre/tmp-iso-output"
preseed_cfg="$HOME/b42/cursus/born2beroot/preseed.cfg"
dest_folder="$HOME/goinfre/iso-output"

[ -d "$tmp_folder" ] || mkdir "$tmp_folder"

docker run \
	--mount "type=bind,src=${src_iso},target=/debian.iso" \
	--mount "type=bind,src=${tmp_folder},target=/output" \
	--mount "type=bind,src=${preseed_cfg},target=/preseed.cfg" \
	--mount "type=bind,src=./install_preseed_to_iso.sh,target=/install_preseed_to_iso.sh" \
	yatheo/xorriso:v0.1 \
		bash -c "bsdtar --preserve-permissions --extract --file /debian.iso --directory /output && bash /install_preseed_to_iso.sh"
		

# xorriso -osirrox on -indev "$src_iso" -extract / "$tmp_folder"

# cp -rT "${src_folder}" "${tmp_folder}"
# mkdir -p "${tmp_folder}/preseed"
# cp ${preseed_cfg} "${tmp_folder}/preseed/"

# chmod u+w "${tmp_folder}/isolinux/txt.cfg"
# cat <<EOF | tee -a "${tmp_folder}/isolinux/txt.cfg"

# default auto
# label auto
	# menu label a^Utomated Install
	# kernel /install.amd/vmlinuz
	# append initrd=/install.amd/initrd.gz preseed/file=/cdrom/preseed/preseed.cfg language=en country=DE locale=en_US.UTF-8 keymap=us
# EOF

# sed -i.bak -e 's/default installgui/default auto/' "${tmp_folder}/isolinux/gtk.cfg"


mkdir -p "${dest_folder}"
docker run \
	--mount "type=bind,src=${tmp_folder},target=/input" \
	--mount "type=bind,src=${dest_folder},target=/iso-output" \
	yatheo/xorriso:v0.1 \
	xorrisofs \
		-o "/iso-output/debian-preseed.iso" \
		-r -J -no-emul-boot \
		-boot-load-size 4 -boot-info-table \
		-b isolinux/isolinux.bin \
		-c isolinux/boot.cat \
		-input-charset utf-8 \
		-iso-level 2 \
		"/input"
