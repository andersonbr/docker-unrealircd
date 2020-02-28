#!/bin/sh

DIR=/tmp

gcc -I$DIR/unrealircd-5.0.3.1/include -pthread \
  -I$DIR/unrealircd-5.0.3.1/extras/pcre2/include \
  -I$DIR/unrealircd-5.0.3.1/extras/argon2/include \
  -I$DIR/unrealircd-5.0.3.1/extras/c-ares/include -g \
  -O2 -fno-strict-aliasing -fno-common -funsigned-char \
  -Wall -Wextra -Waggregate-return -Wduplicated-cond \
  -Wduplicated-branches -Wno-pointer-sign -Wno-format-zero-length \
  -Wno-format-truncation -Wno-unused -Wno-unused-parameter -Wno-unused-but-set-parameter \
  -Wno-char-subscripts -Wno-sign-compare -Wno-empty-body -Wno-address -Wno-cast-function-type \
  -fno-strict-overflow -D_FORTIFY_SOURCE=2 \
  -fstack-protector-all -Wstack-protector --param ssp-buffer-size=1 -fPIC -DPIC \
  -shared -Wl,-export-dynamic -DDYNAMIC_LINKING \
        -o websocket.so websocket.c
