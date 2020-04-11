FROM nvidia/cuda:10.1-runtime-ubuntu18.04
LABEL maintainer="Tiago Ferreira <me@tiferrei.com>"

# Env Variables for nvidia
ENV DEBIAN_FRONTEND noninteractive
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES compute,utility
ENV NVIDIA_REQUIRE_CUDA "cuda>=8.0"

# Env Variables for FAH
ENV USER ""
ENV TEAM ""
ENV PASSKEY ""

RUN mkdir -p /usr/share/doc/fahclient/
RUN touch /usr/share/doc/fahclient/sample-config.xml

# Download/Install latest FAH client
# See here for latest - https://foldingathome.org/alternative-downloads/
RUN apt-get update && \
  apt install wget -y && \
  wget https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit/v7.5/fahclient_7.5.1_amd64.deb && \
  dpkg -i --force-depends fahclient_7.5.1_amd64.deb && \
  rm fahclient*.deb

# Install Opencl 
RUN apt install ocl-icd-opencl-dev ocl-icd-libopencl1 nvidia-opencl-dev -y

# To keep down the size of the image, clean out that cache when finished installing packages.
RUN apt-get clean -y && apt-get autoclean -y && rm -rf /var/lib/apt/lists/* && apt-get autoremove -y

EXPOSE 7396 36330

WORKDIR /var/lib/fahclient
CMD ["sh", "-c", "/usr/bin/FAHClient --pid-file=/var/run/fahclient.pid --user=\"${USER}\" --team=\"${TEAM}\" --passkey=\"${PASSKEY}\" --power=full --gui-enabled=false --gpu=true --smp=true --allow=\"0/0\""]
