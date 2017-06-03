  
 ./configure \
    --prefix=./linux/x86_64 \
    --arch=x86_64 \
    --cc=clang \
    --enable-pic \
    --extra-cflags="-fpic -fvisibility=hidden -fdata-sections -ffunction-sections" \
    --disable-shared \
    --enable-static \
    --enable-zlib \
    --disable-everything \
    --enable-runtime-cpudetect \
    --enable-swscale --disable-gpl --enable-decoder=aac --enable-decoder=h264 --enable-decoder=aac_latm --enable-demuxer=h264 --enable-demuxer=aac --enable-demuxer=mov --enable-parser=h264 --enable-parser=aac --enable-protocol=file --enable-hwaccel=h264-dxva2 --disable-debug --disable-ffmpeg --disable-ffprobe --disable-ffserver

