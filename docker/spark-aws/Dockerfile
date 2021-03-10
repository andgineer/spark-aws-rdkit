FROM debian:stretch

ARG SPARK_VERSION=3.0.2
ARG HADOOP_VERSION=3.2.0
ARG JAVA_JDK=openjdk-8-jre

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED 0 \
    PYTHONIOENCODING UTF-8 \
    PIP_DISABLE_PIP_VERSION_CHECK 1

ENV LANG en_US.UTF-8 \
    LANGUAGE en_US:en \
    LC_ALL en_US.UTF-8 \
    HADOOP_HOME /usr/hadoop-$HADOOP_VERSION \
    ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop \
    PATH $PATH:$HADOOP_HOME/bin \
    SPARK_PACKAGE spark-${SPARK_VERSION}-bin-without-hadoop \
    SPARK_HOME /usr/spark-${SPARK_VERSION} \
    SPARK_DIST_CLASSPATH="$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*" \
    PATH $PATH:${SPARK_HOME}/bin

RUN apt-get update \
 && apt-get install -y locales curl unzip \
    ${JAVA_JDK} telnet dnsutils \
 && dpkg-reconfigure -f noninteractive locales \
 && locale-gen C.UTF-8 \
 && /usr/sbin/update-locale LANG=C.UTF-8 \
 && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
 && locale-gen \
 && mkdir -p /recovery \
 && curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr \
 && rm -rf $HADOOP_HOME/share/doc \
 && chown -R root:root $HADOOP_HOME \
 && curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && chown -R root:root $SPARK_HOME \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

WORKDIR $SPARK_HOME
