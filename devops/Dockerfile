FROM nimlang/nim
RUN : \
    && apt-get update -y --quiet \
    && apt-get install -y firejail webp
RUN nimble -y refresh
RUN nimble -y install nimwc@4.5.0
# RUN nimble -y install https://github.com/ThomasTJdev/nim_websitecreator.git
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/ /tmp/*
EXPOSE 5000
EXPOSE 7000
