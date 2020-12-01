FROM ubuntu:18.04
MAINTAINER Chris Troutner <chris.troutner@gmail.com>

# Update the OS and install any OS packages needed.
RUN apt-get update
RUN apt-get install -y sudo git curl nano gnupg wget

# Install Node and NPM
# (used for debugging)
#RUN curl -sL https://deb.nodesource.com/setup_12.x -o nodesource_setup.sh
#RUN bash nodesource_setup.sh
#RUN apt-get install -y nodejs build-essential

# Create bitcoin user and group.
RUN groupadd -r bitcoin && useradd -r -m -g bitcoin bitcoin

# Install basic software packages.
RUN set -ex \
	&& apt-get update \
	&& apt-get install -qq --no-install-recommends -y curl wget gpg sudo \
	software-properties-common gpg-agent

# create data directory
ENV BITCOIN_DATA /data
RUN mkdir "$BITCOIN_DATA"
RUN chown -R bitcoin:bitcoin "$BITCOIN_DATA"
RUN ln -sfn "$BITCOIN_DATA" /home/bitcoin/.bitcoin
#COPY bitcoin.conf /home/bitcoin/bitcoin.conf
RUN chown -h bitcoin:bitcoin /home/bitcoin/.bitcoin

# Install Bitcoin ABC from the Linux PPA
# RUN add-apt-repository ppa:bitcoin-abc/ppa
# RUN apt-get update
# RUN apt-get install -y bitcoind

# Install Bitcoin ABC from binary release
ENV TARFILE bitcoin-abc-0.22.8-x86_64-linux-gnu.tar.gz
ENV TARDIR bitcoin-abc-0.22.8
RUN wget https://download.bitcoinabc.org/bcha/0.22.8/linux/$TARFILE
RUN tar -xvf $TARFILE
RUN mv $TARDIR/bin/* /usr/bin/

# Make persistant config directory
RUN mkdir /home/bitcoin/config

# These values will need to be set at run time.
VOLUME /data
VOLUME /home/bitcoin/config
EXPOSE 8332 8333 28332

#CMD ["bitcoind", "-conf=/home/bitcoin/bitcoin.conf", "-datadir=/data", "-disablewallet"]
#CMD ["bitcoind", "-conf=/data/bitcoin.conf", "-datadir=/data", "-disablewallet"]

# Startup script that will copy in config settings at startup.
WORKDIR /home/bitcoin
COPY startup-script.sh startup-script.sh
CMD ["./startup-script.sh"]
