echo "deb http://ftp.debian.org/debian sid main" >> /etc/apt/sources.list
apt-get update
apt-get -t sid install libc6 libc6-dev libc6-dbg
apt-get install -y wget unzip git make python-serial srecord bc xz-utils gcc
cd /opt && git clone https://github.com/nodemcu/nodemcu-firmware.git
cd /opt/nodemcu-firmware
if [ -z "$IMAGE_NAME" ]; then \
      BRANCH="$(git rev-parse --abbrev-ref HEAD | sed -r 's/[\/\\]+/_/g')" && \
      BUILD_DATE="$(date +%Y%m%d-%H%M)" && \
      IMAGE_NAME=${BRANCH}_${BUILD_DATE}; \
    else true; fi && \
    cp tools/esp-open-sdk.tar.* ../ && \
    cd ..  && \
    if [ -f ./esp-open-sdk.tar.xz ]; then \
        tar -Jxvf esp-open-sdk.tar.xz; \
    else \
        tar -zxvf esp-open-sdk.tar.gz; \
    fi && \
    export PATH=$PATH:$PWD/esp-open-sdk/sdk:$PWD/esp-open-sdk/xtensa-lx106-elf/bin  && \
    cd nodemcu-firmware  && \
    if [ -z "$INTEGER_ONLY" ]; then \
      (make clean all && \
      cd bin  && \
      srec_cat -output nodemcu_float_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000 && \
      cp ../app/mapfile nodemcu_float_"${IMAGE_NAME}".map && \
      cd ../); \
    else true; fi && \
    if [ -z "$FLOAT_ONLY" ]; then \
      (make EXTRA_CCFLAGS="-DLUA_NUMBER_INTEGRAL" clean all && \
      cd bin && \
      srec_cat -output nodemcu_integer_"${IMAGE_NAME}".bin -binary 0x00000.bin -binary -fill 0xff 0x00000 0x10000 0x10000.bin -binary -offset 0x10000 && \
      cp ../app/mapfile nodemcu_integer_"${IMAGE_NAME}".map); \
    else true; fi
