FROM nimlang/nim
RUN nimble -y refresh
RUN nimble -y install nimwc@4.0.12
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/ /tmp/*
