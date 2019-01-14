FROM ubuntu:16.04
WORKDIR /workspace

# Install the tools in ubuntu...
RUN apt-get update && \
    apt-get install -y \
            build-essential \
            git \
            libdb-dev \
            libsodium-dev \
            libtinfo-dev \
            sysvbanner \
            unzip \
            wget \
            wrk \
            zlib1g-dev

# Install Golang
ENV GOREL go1.7.3.linux-amd64.tar.gz
ENV PATH $PATH:/usr/local/go/bin

RUN wget -q https://storage.googleapis.com/golang/$GOREL && \
    tar xfz $GOREL && \
    mv go /usr/local/go && \
    rm -f $GOREL


# Install Quorum 2.1.1 & Swarm 1.7.2-stable

RUN git clone https://github.com/jpmorganchase/quorum.git && \
    cd quorum && \
    git checkout tags/v2.1.1 && \
    make all && \
    cp build/bin/geth /usr/local/bin && \
    cp build/bin/bootnode /usr/local/bin && \
    cd .. && \
    rm -rf quorum

# Install Swarm
    cp build/bin/swarm /usr/local/bin


# Install Java 8
RUN apt-get update
RUN apt-get install -y \
	    software-properties-common \
	    python-software-properties && \
    apt-add-repository -y ppa:webupd8team/java && \
    apt-get update && \
    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections && \
    apt-get install -y oracle-java8-installer

ENV JAVA_HOME /usr/lib/jvm/java-8-oracle
RUN export JAVA_HOME
ENV PATH $PATH:$JAVA_HOME

# Install Maven (version should > 3.5.0)
# RUN apt-get install -y maven (only provide 3.3.9)

RUN wget http://ftp.twaren.net/Unix/Web/apache/maven/maven-3/3.6.0/binaries/apache-maven-3.6.0-bin.tar.gz
RUN tar -xvzf apache-maven-3.6.0-bin.tar.gz
RUN rm apache-maven-3.6.0-bin.tar.gz
RUN mv apache-maven-3.6.0 maven
RUN mv maven /opt/

ENV M2_HOME=/opt/maven
ENV PATH $PATH:$M2_HOME/bin
RUN /bin/bash -c "source ~/.bashrc"

# Install Tessera 

RUN git clone https://github.com/jpmorganchase/tessera.git && \
    cd tessera && \
    mvn install -DskipTests

RUN mv /workspace/tessera/tessera-app/target/tessera-app-0.8-SNAPSHOT-app.jar /workspace
RUN rm -r /workspace/tessera && \
    mkdir /workspace/tessera && \
    mkdir /workspace/tessera/app && \
    mv /workspace/tessera-app-0.8-SNAPSHOT-app.jar /workspace/tessera/app

COPY setup.sh /workspace
RUN  mkdir /workspace/lib
COPY lib /workspace/lib

CMD ["/setup.sh"]
