#!/bin/sh

# directories
FAT="FFmpeg-Mac"

SCRATCH=$FAT/"scratch"
# must be an absolute path
THIN=`pwd`/$FAT/"thin"

# absolute path to x264 library
#X264=`pwd`/fat-x264

#FDK_AAC=`pwd`/fdk-aac/fdk-aac-ios

CONFIGURE_FLAGS="--enable-swscale --disable-gpl --enable-static --disable-programs --disable-ffmpeg --disable-ffplay --disable-ffprobe --disable-ffserver --disable-doc  --disable-avdevice --disable-postproc --disable-avfilter --disable-everything --enable-decoder=aac --enable-decoder=h264 --enable-decoder=aac_latm --enable-demuxer=h264 --enable-demuxer=aac --enable-demuxer=mov --enable-parser=h264 --enable-parser=aac --enable-protocol=file --enable-hwaccel=h264-dxva2 --disable-debug --enable-cross-compile"

# avresample
#CONFIGURE_FLAGS="$CONFIGURE_FLAGS --enable-avresample"

ARCHS="x86_64"

COMPILE="y"
LIPO="y"

DEPLOYMENT_TARGET="10.8"

if [ ! `which yasm` ]
then
echo 'Yasm not found'
if [ ! `which brew` ]
then
echo 'Homebrew not found. Trying to install...'
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" \
|| exit 1
fi
echo 'Trying to install Yasm...'
brew install yasm || exit 1
fi
if [ ! `which gas-preprocessor.pl` ]
then
echo 'gas-preprocessor.pl not found. Trying to install...'
(curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl \
-o /usr/local/bin/gas-preprocessor.pl \
&& chmod +x /usr/local/bin/gas-preprocessor.pl) \
|| exit 1
fi

CWD=`pwd`
for ARCH in $ARCHS
do
echo "building $ARCH..."
mkdir -p "$SCRATCH/$ARCH"
cd "$SCRATCH/$ARCH"

CFLAGS="-arch $ARCH -ffunction-sections -fdata-sections -fvisibility=hidden"
CFLAGS="$CFLAGS -mmacosx-version-min=$DEPLOYMENT_TARGET"
PLATFORM="MacOSX"

XCRUN_SDK=`echo $PLATFORM | tr '[:upper:]' '[:lower:]'`
CC="xcrun -sdk $XCRUN_SDK clang"
CXXFLAGS="$CFLAGS"
LDFLAGS="$CFLAGS"

echo $CWD
$CWD/configure \
--target-os=darwin \
--arch=$ARCH \
--cc="$CC" \
--enable-pic \
$CONFIGURE_FLAGS \
--extra-cflags="$CFLAGS" \
--extra-cxxflags="$CXXFLAGS" \
--extra-ldflags="$LDFLAGS" \
--prefix="$THIN/$ARCH" \
|| exit 1

make -j8 install $EXPORT || exit 1
cd $CWD
done


echo "building fat binaries..."
mkdir -p $FAT/lib
set - $ARCHS
CWD=`pwd`
cd $THIN/$1/lib
for LIB in *.a
do
cd $CWD
echo lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB 1>&2
lipo -create `find $THIN -name $LIB` -output $FAT/lib/$LIB || exit 1
done

cd $CWD
cp -rf $THIN/$1/include $FAT

echo Done

