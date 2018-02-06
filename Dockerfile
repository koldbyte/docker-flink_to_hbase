# Flink to HBase in Docker
#
# Version 1.3

# http://docs.docker.io/en/latest/use/builder/

FROM ubuntu:xenial

LABEL maintainer="Federico Soldani <pippo@daemon-ware.com>"
LABEL version="1.3"
LABEL description="Image for realtime analyzing with Flink stream processing and HBase storage"


# Configure version
ENV FLINK_VERSION=1.4.0 \
    HADOOP_VERSION=27 \
    SCALA_VERSION=2.11 \
    HBASE_VERSION=1.3.1 \
    KAFKA_VERSION=0.11.0.2 \
    KAFKA_API_VERSION=0.11.0.2 \
    ZOOKEEPER_VERSION=3.4.10 \
#    JMX_PORT=7203 \
    VIEWER_PATH=/data/viewer/factsViewer.jar

COPY *.sh /build/

RUN chmod +x /build/*.sh \
    && /build/prepare-system.sh \
    && /build/prepare-kafka.sh \
    && /build/prepare-flink.sh \
    && /build/prepare-zookeeper.sh \
    && /build/prepare-hbase.sh \
    && cd /opt/hbase && /build/build-hbase.sh \
    && /build/cleanup.sh

VOLUME /data

COPY ./flink-conf.yaml /opt/flink/conf/flink-conf.yaml
COPY ./hbase-site.xml /opt/hbase/conf/hbase-site.xml
COPY ./zoo.cfg /opt/hbase/conf/zoo.cfg
COPY ./replace-hostname /opt/replace-hostname
COPY ./config-kafka /opt/kafka/config

COPY ./print-logo /opt/print-logo
COPY ./hbase-server /opt/hbase-server
COPY ./flink-server /opt/flink-server
COPY ./kafka-server /opt/kafka-server
COPY ./viewer-server /opt/viewer-server

RUN chmod +x /opt/print-logo \
    && chmod +x /opt/hbase-server \
    && chmod +x /opt/flink-server \
    && chmod +x /opt/kafka-server \
    && chmod +x /opt/viewer-server

# REST API
EXPOSE 8080
# REST Web UI at :8085/rest.jsp
EXPOSE 8085
# Thrift API
EXPOSE 9090
# KAFKA
EXPOSE 9092
# Thrift Web UI at :9095/thrift.jsp
EXPOSE 9095
# HBase's Embedded zookeeper cluster
EXPOSE 2181
# HBase Master port
EXPOSE 16000
# HBase Master web UI at :16010/master-status;  ZK at :16010/zk.jsp
EXPOSE 16010
# HBase Region Servers
EXPOSE 16020 16030
# Flink
EXPOSE 6123
# JMX
#EXPOSE ${JMX_PORT}
# Flink web UI
EXPOSE 8081
# SpringBoot Viewer web UI
EXPOSE 8090

CMD "/opt/print-logo"; "/opt/flink-server"; "/opt/viewer-server"; "/opt/kafka-server"; "/opt/hbase-server";