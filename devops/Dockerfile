FROM archlinux/base
RUN export CHOOSENIM_NO_ANALYTICS=1 ; export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH ; echo "PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> ~/.profile ; echo "PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> ~/.bashrc ; echo "PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> /root/.profile ; echo "PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> /root/.bashrc ; source /root/.bashrc
RUN pacman -Syu --needed --noconfirm --quiet git pacman-contrib base-devel libwebp firejail
RUN curl -sfk https://nim-lang.org/choosenim/init.sh > init.sh && sh init.sh -y
RUN /root/.nimble/bin/nimble -y refresh
RUN git clone https://github.com/ThomasTJdev/nim_websitecreator.git
COPY config.cfg /nim_websitecreator/config
# install dependencies
RUN cd nim_websitecreator && /root/.nimble/bin/nimble install -dy
RUN cd nim_websitecreator && /root/.nimble/bin/nim c -d:release -d:ssl -d:sqlite --passL:"-s" /nimwc.nim
RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/* /tmp/* /var/log/journal/*
EXPOSE 5000
EXPOSE 7000
