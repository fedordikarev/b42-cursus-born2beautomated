#!/bin/bash

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
		# bash -c "bash /install_preseed_to_iso.sh"
		

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
