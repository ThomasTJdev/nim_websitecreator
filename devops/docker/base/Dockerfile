FROM nimlang/nim
RUN git clone https://github.com/ThomasTJdev/nim_websitecreator.git
WORKDIR /nim_websitecreator/
# install dependencies
# firejail does not work in docker
RUN nimble install -dy && nimble remove -y firejail
#compile
RUN rm nimwc.nim.cfg && nim c -d:release -d:webp -d:ssl -d:sqlite --passL:"-s" nimwc.nim
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/* /tmp/* /var/log/journal/* 
EXPOSE 7000
