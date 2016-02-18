FROM podbox/debian

# ------------------------------------------------------------------------ java8
RUN (curl -L -k -b "oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u74-b02/server-jre-8u74-linux-x64.tar.gz | gunzip -c | tar x) \
 && mv /jdk1.8.0_74 /jdk

ENV JAVA_HOME /jdk
ENV JRE_HOME  $JAVA_HOME/jre
ENV PATH $PATH:$JAVA_HOME/bin

# --------------------------------------------------------------------- tcnative
ENV APR_VERSION 1.5.2
ENV TCNATIVE_VERSION 1.2.4

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

 && apt-get -qq autoremove -y build-essential libssl-dev libpcre++-dev zlib1g-dev \
 && apt-get -qq clean \
 && rm -fR /tmp/* /apr-* /tomcat-native-*
