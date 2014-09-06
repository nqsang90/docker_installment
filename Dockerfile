FROM dockerfile/java
MAINTAINER Sang Nguyen <sang.nguyen@mobivi.com>

ENV JAVA_HOME /usr/lib/jvm/java-7-oracle

# daemon install
RUN wget http://10.120.29.29:18888/daemon/0.0.1.tgz -O /daemon.tgz
RUN mkdir -p /opt/installment && tar xzf /daemon.tgz -C /opt/installment && rm /daemon.tgz
RUN mv /opt/installment/daemon.properties /opt/installment/installment.properties

RUN sed -i s/{{daemon}}/installment/g /opt/installment/bin/daemon.sh
RUN mv /opt/installment/bin/daemon.sh /opt/installment/bin/installment.sh
RUN mv /opt/installment/bin/daemon /opt/installment/bin/installment

# install cpan URI::Escape
RUN cpan App::cpanminus
RUN cpanm URI::Escape

# log config
ADD conf/daemon/log4j.properties /opt/installment/config/
ADD conf/daemon/log4j2.xml /opt/installment/config/
ADD conf/daemon/simplelog.properties /opt/installment/config/

# id-generator and embedded-webapp
RUN wget http://10.120.29.29:18888/id-generator/0.1.1.tgz -O /id-generator.tgz
RUN mkdir -p /opt/installment/modules/id-generator && tar xzf /id-generator.tgz -C /opt/installment/modules/id-generator && rm /id-generator.tgz

RUN wget http://10.120.29.29:18888/embedded-webapp/0.1.1.tgz -O /embedded-webapp.tgz
RUN mkdir -p /opt/installment/modules/embedded-webapp && tar xzf /embedded-webapp.tgz -C /opt/installment/modules/embedded-webapp && rm /embedded-webapp.tgz

# installment module
RUN wget http://10.120.29.29:18888/installment/0.6.13-alpha1-r3.tgz -O /installment.tgz
RUN mkdir -p /opt/installment/modules/installment && tar xzf /installment.tgz -C /opt/installment/modules/installment && rm /installment.tgz

ADD conf/embedded-webapp/embedded-webapp.conf /opt/installment/modules/embedded-webapp/
ADD conf/installment/* /opt/installment/modules/installment/

EXPOSE 8383
RUN mkdir -p /opt/installment/logs/ && touch /opt/installment/logs/installment.log
CMD /opt/installment/bin/installment.sh start && tailf /opt/installment/logs/installment.log

