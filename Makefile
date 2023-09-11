mapledos.img: limine.cfg build/mapledos.elf
	dd if=/dev/zero of=$@.tmp bs=64MiB count=1 status=none
	parted $@.tmp -s mklabel gpt \
		mkpart fat32 0% 100% \
		set 1 esp on
	dd if=$@.tmp of=$@.tmp.1 bs=1b skip=34 count=131004 status=none
	mkfs.vfat -F32 $@.tmp.1
	mkdir -p image
	fusefat $@.tmp.1 image/ -o rw+
	mkdir -p image/EFI/BOOT
	cp /usr/share/limine/BOOTX64.EFI image/EFI/BOOT/
	cp /usr/share/limine/limine-bios.sys image/
	cp $^ image/
	fusermount -u image/
	dd if=$@.tmp.1 of=$@.tmp bs=1b seek=34 conv=notrunc status=none
	$(RM) $@.tmp.1
	$(RM) -r image/
	limine bios-install $@.tmp
	mv $@.tmp $@

build/mapledos.elf: kernel/mapledos.nim build
	nim c -o:$@ $<

build:
	mkdir -p build

.PHONY: clean
clean:
	$(RM) -r mapledos.elf build/ image/ $(wildcard mapledos.img*)