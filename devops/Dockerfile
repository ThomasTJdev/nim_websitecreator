FROM nimlang/nim
RUN nimble -y refresh
RUN nimble -y install nimwc@4.5.0
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/ /tmp/*
