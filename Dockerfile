FROM debian:stretch-slim

ENV BUILD_PACKAGES="\
        build-essential \
        python3.5-dev \
        cmake \
        tcl-dev \
        xz-utils \
        zlib1g-dev \
        git \
        curl" \
    APT_PACKAGES="\
        ca-certificates \
        openssl \
        bash \
        pkg-config \
        graphviz \
        libpng-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libopenblas-dev \
        libatlas-base-dev \
        python3.5 \
        python3-pip" \
    PIP_PACKAGES=" \
        numpy \
        pandas \
        matplotlib \
        jupyter" \
    PATH=/usr/local/bin:$PATH \
    JUPYTER_CONFIG_DIR=/home/.ipython/profile_default/startup \
    LANG=C.UTF-8

RUN set -ex;
RUN apt-get update -y;
RUN apt-get install -y --no-install-recommends ${APT_PACKAGES};
RUN apt-get install -y --no-install-recommends ${BUILD_PACKAGES};
RUN pip3 install -U -v setuptools wheel;
RUN bash -c 'echo -e "[global]\nextra-index-url=https://www.piwheels.org/simple" > /etc/pip.conf'
RUN pip3 install -U ${PIP_PACKAGES};
RUN apt-get remove --purge --auto-remove -y ${BUILD_PACKAGES};
    #apt-get clean;
    #apt-get autoclean;
    #apt-get autoremove;
    #rm -rf /tmp/* /var/tmp/*;
    #rm -rf /var/lib/apt/lists/*;
    #rm -f /var/cache/apt/archives/*.deb
    #    /var/cache/apt/archives/partial/*.deb
    #    /var/cache/apt/*.bin; \
    #find /usr/lib/python3 -name __pycache__ | xargs rm -r; \
    #rm -rf /root/.[acpw]*; \
RUN pip3 install jupyter && jupyter nbextension enable --py widgetsnbextension;
RUN mkdir -p ${JUPYTER_CONFIG_DIR};
RUN echo "import warnings" | tee ${JUPYTER_CONFIG_DIR}/config.py;
RUN echo "warnings.filterwarnings('ignore')" | tee -a ${JUPYTER_CONFIG_DIR}/config.py;
RUN echo "c.NotebookApp.token = u''" | tee -a ${JUPYTER_CONFIG_DIR}/config.py

RUN apt-get install -y --no-install-recommends python python-dev python-pip libzmq3-dev
RUN python2 -m pip install -U pip setuptools
RUN python2 -m pip install ipykernel && python2 -m ipykernel install --user

RUN apt-get -y install --no-install-recommends ipython curl gnupg
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y install --no-install-recommends nodejs
RUN apt-get -y install make g++
RUN npm install -g ijavascript --unsafe-perm=true --allow-root --zmq-external
RUN ijsinstall

RUN curl https://dl.google.com/go/go1.11.linux-armv6l.tar.gz |  tar -C /usr/local -xz
RUN mkdir /go
RUN apt-get -y install git

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN go get github.com/yunabe/lgo/cmd/lgo && go get -d github.com/yunabe/lgo/cmd/lgo-internal

RUN mkdir /igo
ENV LGOPATH /igo
RUN lgo install
RUN python3 $(go env GOPATH)/src/github.com/yunabe/lgo/bin/install_kernel


WORKDIR /home/notebooks

EXPOSE 8888

CMD [ "jupyter", "notebook", "--port=8888", "--no-browser", \
    "--allow-root", "--ip=0.0.0.0", "--NotebookApp.token=" ]
