all: hello.efi

%.o: %.cpp
	clang++ -target x86_64-pc-win32-coff -mno-red-zone -fno-stack-protector -fshort-wchar -fno-finite-loops -Wall -O3 -o $@ -c $<

%.efi: %.o
	lld-link /subsystem:efi_application /entry:EfiMain /out:$@ $<

.PHONY: run
run: hello.efi
	../../devenv/run_qemu.sh hello.efi

clean:
	rm -f hello.efi
	rm -f disk.img
	rm -rf mnt
