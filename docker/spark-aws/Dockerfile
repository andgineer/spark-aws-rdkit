FROM debian:stable-slim

ARG SPARK_VERSION=3.5.2
ARG HADOOP_VERSION=3.3.6
ARG JAVA_JDK=openjdk-17-jre-headless

ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# non-root user for the container
ARG USER_NAME=spark

# http://blog.stuart.axelbrooke.com/python-3-on-spark-return-of-the-pythonhashseed
ENV PYTHONHASHSEED=0
ENV PYTHONIOENCODING=UTF-8
ENV PIP_DISABLE_PIP_VERSION_CHECK=1

ENV HADOOP_HOME=/usr/hadoop-$HADOOP_VERSION
ENV HADOOP_CONF_DIR=$HADOOP_HOME/etc/hadoop
ENV SPARK_PACKAGE=spark-${SPARK_VERSION}-bin-without-hadoop
ENV SPARK_HOME=/usr/spark-${SPARK_VERSION}
ENV SPARK_DIST_CLASSPATH=$HADOOP_HOME/etc/hadoop/*:$HADOOP_HOME/share/hadoop/common/lib/*:$HADOOP_HOME/share/hadoop/common/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/hdfs/lib/*:$HADOOP_HOME/share/hadoop/hdfs/*:$HADOOP_HOME/share/hadoop/yarn/lib/*:$HADOOP_HOME/share/hadoop/yarn/*:$HADOOP_HOME/share/hadoop/mapreduce/lib/*:$HADOOP_HOME/share/hadoop/mapreduce/*:$HADOOP_HOME/share/hadoop/tools/lib/*

# For Linux change to "localhost"
ENV SPARK_PUBLIC_DNS=docker.for.mac.localhost

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y locales \
 && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
 && dpkg-reconfigure --frontend=noninteractive locales \
 && update-locale LANG=en_US.UTF-8 \
 && mkdir -p /recovery \
 && apt-get install -y curl unzip ${JAVA_JDK} telnet dnsutils \
 && curl -sL --retry 3 \
  "http://archive.apache.org/dist/hadoop/common/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz" \
  | gunzip \
  | tar -x -C /usr \
 && rm -rf $HADOOP_HOME/share/doc \
 && curl -sL --retry 3 \
  "https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/${SPARK_PACKAGE}.tgz" \
  | gunzip \
  | tar x -C /usr/ \
 && mv /usr/$SPARK_PACKAGE $SPARK_HOME \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -ms /bin/bash $USER_NAME \
 && chown -R $USER_NAME $HADOOP_HOME \
 && chown -R $USER_NAME $SPARK_HOME \
 && chown -R $USER_NAME /recovery

COPY --chown=${USER_NAME} start.sh /scripts/
RUN chmod +x /scripts/start.sh

USER $USER_NAME

COPY conf /conf

ENV PATH=$PATH:$HADOOP_HOME/bin:${SPARK_HOME}/bin
SHELL ["/bin/bash", "-c"]
WORKDIR $SPARK_HOME
CMD /scripts/start.sh

