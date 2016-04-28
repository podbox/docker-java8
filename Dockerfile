FROM ubuntu:xenial

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN apt-get -qq update     \
 && apt-get -qq upgrade -y \
 && apt-get -qq install -y curl unzip

# ------------------------------------------------------------------------ java8
RUN (curl -L -k -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/server-jre-8u92-linux-x64.tar.gz | gunzip -c | tar x) \
 && mv /jdk1.8.0_92 /jdk

RUN cd /tmp && curl -L -O -k -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip \
 && unzip jce_policy-8.zip \
 && mv UnlimitedJCEPolicyJDK8/*.jar /jdk/jre/lib/security/ \
 && rm -fR jce_policy-8.zip UnlimitedJCEPolicyJDK8

ENV JAVA_HOME /jdk
ENV JRE_HOME  $JAVA_HOME/jre
ENV PATH $PATH:$JAVA_HOME/bin

# --------------------------------------------------------------------- tcnative
ENV APR_VERSION 1.5.2
ENV TCNATIVE_VERSION 1.2.6

RUN apt-get -qq update \
 && apt-get -qq install -y build-essential libssl-dev libpcre++-dev zlib1g-dev \

 && (curl -L http://www.us.apache.org/dist/apr/apr-$APR_VERSION.tar.gz | gunzip -c | tar x) \
 && cd apr-$APR_VERSION \
 && ./configure \
 && make install \

 && (curl -L http://www.us.apache.org/dist/tomcat/tomcat-connectors/native/$TCNATIVE_VERSION/source/tomcat-native-$TCNATIVE_VERSION-src.tar.gz | gunzip -c | tar x) \
 && cd tomcat-native-$TCNATIVE_VERSION-src/native \
 && ./configure --with-java-home=$JAVA_HOME --with-apr=/usr/local/apr --prefix=/usr \
 && make install \

 && apt-get -qq purge -y build-essential dpkg-dev g++ gcc libc6-dev make libssl-dev libpcre++-dev zlib1g-dev \
 && apt-get -qq autoremove -y \
 && apt-get -qq clean \
 && rm -fR /tmp/* /apr-* /tomcat-native-*
