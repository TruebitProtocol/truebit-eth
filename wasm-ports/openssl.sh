#!/bin/sh

wget https://www.openssl.org/source/openssl-1.1.0h.tar.gz
tar xf openssl-1.1.0h.tar.gz
cd openssl-1.1.0h

sed -i '1s/^/#define NO_SYSLOG\n/' crypto/bio/bss_log.c

wasiconfigure ./Configure no-hw no-shared no-asm no-threads no-ssl3 no-dtls no-engine no-dso no-sock no-posix-io linux-x32 -static
# emconfigure ./Configure linux-generic64 --prefix=$EMSCRIPTEN/system

# sed -i 's|^CROSS_COMPILE.*$|CROSS_COMPILE=|g' Makefile

export SYSROOT=~/.local/lib/python3.10/site-packages/wasienv-storage/sdks/8/wasi-sdk-8.0/share/wasi-sysroot/

wasimake make -j 12 build_generated 
wasimake make -j 12 libssl.a
wasimake make -j 12 libcrypto.a
rm -rf $SYSROOT/include/openssl
cp -R include/openssl $SYSROOT/include
cp libcrypto.a libssl.a $SYSROOT/lib/wasm32-wasi
