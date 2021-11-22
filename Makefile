all:
	python bin/encode.py
	nasm src/double_helix.asm -o double_helix.mbr

clean:
	rm -f *.bin double_helix.mbr

test: all
	qemu-system-x86_64 -monitor stdio -drive format=raw,file=double_helix.mbr

encode:
	python bin/encode.py

decode:
	python bin/decode.py
