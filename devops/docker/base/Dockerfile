FROM archlinux/base
ENV PATH=/root/.nimble/bin:$PATH
RUN export CHOOSENIM_NO_ANALYTICS=1 
RUN pacman -Syu --needed --noconfirm --quiet git libwebp firejail base-devel
RUN curl -sfk https://nim-lang.org/choosenim/init.sh > init.sh && sh init.sh -y
RUN nimble -y refresh
RUN git clone https://github.com/ThomasTJdev/nim_websitecreator.git
WORKDIR /nim_websitecreator/
# install dependencies
RUN nimble install -dy
#compile
RUN nim c -d:ssl -d:sqlite --passL:"-s" nimwc.nim
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/* /tmp/* /var/log/journal/*
EXPOSE 7000
