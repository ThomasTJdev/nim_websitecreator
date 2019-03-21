FROM archlinux/base
RUN pacman -Syu --needed --noconfirm --quiet --force git pacman-contrib base-devel python-pip ; pip install --upgrade pip==19.0.3

RUN pip install --upgrade flask==1.0.2 django==2.1.7 bottle==0.12.16 vibora==0.0.6 falcon==1.4.1 muffin==0.32.8 tornado==6.0.1 morepath==0.18.2 cherrypy==18.1.0 sanic==18.12.0 japronto==0.1.2 pelican==4.0.1 nikola==8.0.2

RUN export CHOOSENIM_CHOOSE_VERSION="0.19.4" ; export CHOOSENIM_NO_ANALYTICS=1
RUN curl -sfk https://nim-lang.org/choosenim/init.sh > init.sh && sh init.sh -y && /root/.nimble/bin/nimble -y refresh
RUN export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH ; echo "export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> ~/.profile ; echo "export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> ~/.bashrc ; echo "export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> /root/.profile ; echo "export PATH=$HOME/.nimble/bin:/root/.nimble/bin:$PATH" >> /root/.bashrc ; source $HOME/.bashrc
RUN nim --version
RUN /root/.nimble/bin/nimble -y install jester@0.4.1 recaptcha@1.0.2 bcrypt@0.2.1 datetime2human@0.2.2 otp@0.1.1 firejail@0.5.0 webp@0.2.0 libravatar@0.4.0

RUN git clone https://github.com/ThomasTJdev/nim_websitecreator.git && cd nim_websitecreator
RUN /root/.nimble/bin/nim c -d:release -d:ssl --passL:"-s" --gc:markAndSweep nim_websitecreator/nimwc.nim
RUN /root/.nimble/bin/nim c -d:release -d:ssl --passL:"-s" --gc:markAndSweep nim_websitecreator/nimwcpkg/nimwc.nim

RUN rm -rf /var/lib/apt/lists/* /var/tmp/* /tmp/nimblecache/* /tmp/* /var/log/journal/*
EXPOSE 5000
EXPOSE 7000
