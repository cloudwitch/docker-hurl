FROM ubuntu:bionic as builder
WORKDIR /wd
RUN apt update &&\
    apt-get -y upgrade &&\
    DEBIAN_FRONTEND=noninteractive apt-get -y install git cmake make g++ libssl-dev zlib1g-dev libgoogle-perftools-dev liblzma-dev libunwind8-dev python-requests python-pytest &&\
    rm -rf /var/lib/apt/lists/* &&\
    apt-get clean

RUN git clone https://github.com/VerizonDigital/hurl.git &&\
    cd hurl &&\
    ./build_static_lib.sh &&\
    cd ./build &&\
    make install &&\
    cd .. &&\
    ./build.sh &&\
    cd ./build &&\
    make install

ENV URL=http://127.0.0.1/ CALLS=100 FETCHES=100000

CMD /usr/bin/hurl "$URL" --calls=$CALLS --fetches=$FETCHES

FROM ubuntu:bionic
RUN apt update &&\
    apt-get -y upgrade &&\
    rm -rf /var/lib/apt/lists/* &&\
    apt-get clean

COPY --from=builder /usr/lib/libnghttp2.a /usr/lib/libnghttp2.a
COPY --from=builder /usr/man/man1/hurl.1 /usr/man/man1/hurl.1
COPY --from=builder /usr/bin/hurl /usr/bin/hurl
COPY --from=builder /usr/man/man1/phurl.1 /usr/man/man1/phurl.1
COPY --from=builder /usr/bin/phurl /usr/bin/phurl

ENV URL=http://127.0.0.1/ CALLS=100 FETCHES=100000

CMD /usr/bin/hurl "$URL" --calls=$CALLS --fetches=$FETCHES
