if [ "$NDK" = "" ]; then
    if [ "$ANDROID_NDK_HOME" = "" ]; then
    	NDK=/mnt/workspace/android-ndk-r12b
    else
        NDK=$ANDROID_NDK_HOME
    fi
fi
if [ "$NDK_PLATFORM" = "" ]; then
    NDK_PLATFORM=$NDK/platforms/android-21/arch-arm64
fi
if [ "$NDK_PREBUILT" = "" ]; then
    NDK_PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64
    NDK_PREBUILTLLVM=$NDK/toolchains/llvm/prebuilt/linux-x86_64
fi

GENERAL="\
   --enable-cross-compile \
   --enable-pic \
   --arch=aarch64 \
   --cc=$NDK_PREBUILTLLVM/bin/clang \
   --cross-prefix=$NDK_PREBUILT/bin/aarch64-linux-android- \
   --ld=$NDK_PREBUILTLLVM/bin/clang"
   
 ./configure --target-os=android \
    --prefix=./android/armv8 \
    ${GENERAL} \
    --sysroot=$NDK_PLATFORM \
    --extra-cflags=" -ffunction-sections -fdata-sections --target=aarch64-none-linux-android -O3 -DANDROID -fpic -DPIC -fasm -fno-short-enums -fno-strict-aliasing" \
    --disable-shared \
    --enable-static \
    --extra-ldflags=" -B$NDK_PREBUILT/bin/aarch64-linux-android- --target=aarch64-none-linux-android -nostdlib -lc -lm -ldl -llog" \
    --enable-zlib \
    --disable-everything \
    --enable-runtime-cpudetect \
    --enable-swscale --disable-gpl --enable-decoder=aac --enable-decoder=h264 --enable-decoder=aac_latm --enable-demuxer=h264 --enable-demuxer=aac --enable-demuxer=mov --enable-parser=h264 --enable-parser=aac --enable-protocol=file --enable-hwaccel=h264-dxva2 --disable-debug --disable-ffmpeg --disable-ffprobe --disable-ffserver

make -j8
make install
make clean
