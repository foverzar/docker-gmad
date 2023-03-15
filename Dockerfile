FROM ubuntu:latest as builder

RUN apt-get update && apt-get install -y git wget build-essential

WORKDIR /build

RUN git clone https://github.com/Facepunch/gmad

RUN git clone https://github.com/garrynewman/bootil

RUN wget https://github.com/premake/premake-core/releases/download/v5.0.0-beta2/premake-5.0.0-beta2-linux.tar.gz -O premake5.tar.gz && \
    tar -xvf premake5.tar.gz && \
    rm premake5.tar.gz && \
    mv premake5 /usr/bin/premake5

WORKDIR /build/bootil/projects
RUN premake5 gmake2 && \
    make config=release_x64

WORKDIR /build/gmad

RUN premake5 --outdir="bin/" --bootil_lib="../bootil/projects/release_x64_linux" --bootil_inc="../bootil/include/" gmake2 && \
    make config=release

FROM ubuntu:latest as final

COPY --from=builder /build/gmad/bin/gmad_linux /gmad/gmad

ENTRYPOINT ["/gmad/gmad"]
