# Version: 0.0.1 Weblogic 11g 10.3.6 x64 Generic -- snagged from unbc/weblogic*
FROM unbc/oraclelinux6
MAINTAINER Daniel Ng "danjng@gmail.com"

# System configuration to mee prerequisites to install and run Weblogic 11g 10.3.6
# Requirements from http://docs.oracle.com/html/E25460_01/r2_fr_requirements.htm#sthref11
# Linux x86-64, Oracle Linux 6 UL1+
RUN [ "yum", "install", "binutils.x86_64",            "-y" ]
RUN [ "yum", "install", "compat-libcap1.x86_64",      "-y" ]
RUN [ "yum", "install", "compat-libstdc++-33.x86_64", "-y" ]
RUN [ "yum", "install", "compat-libstdc++-33.i686",   "-y" ]
RUN [ "yum", "install", "gcc.x86_64",                 "-y" ]
RUN [ "yum", "install", "gcc-c++.x86_64",             "-y" ]
RUN [ "yum", "install", "glibc.x86_64",               "-y" ]
RUN [ "yum", "install", "glibc.i686",                 "-y" ]
RUN [ "yum", "install", "glibc-devel.i686",           "-y" ]
RUN [ "yum", "install", "libaio.x86_64",              "-y" ]
RUN [ "yum", "install", "libaio-devel.x86_64",        "-y" ]
RUN [ "yum", "install", "libgcc.x86_64",              "-y" ]
RUN [ "yum", "install", "libstdc++.x86_64",           "-y" ]
RUN [ "yum", "install", "libstdc++.i686",             "-y" ]
RUN [ "yum", "install", "libstdc++-devel.x86_64",     "-y" ]
RUN [ "yum", "install", "libXext.i686",               "-y" ]
RUN [ "yum", "install", "libXtst.i686",               "-y" ]
RUN [ "yum", "install", "openmotif.x86_64",           "-y" ]
RUN [ "yum", "install", "openmotif22.x86_64",         "-y" ]
RUN [ "yum", "install", "redhat-lsb-core.x86_64",     "-y" ]
RUN [ "yum", "install", "sysstat.x86_64",             "-y" ]
RUN [ "yum", "install", "unzip",                      "-y" ]
RUN [ "yum", "install", "wget",                       "-y" ]

# DANJNG
#RUN rngd -r /dev/urandom -o /dev/random -t 1 && \
# echo 'EXTRAOPTIONS="-r /dev/urandom -o /dev/random -t 1"' >> /etc/sysconfig/rngd && \
# chkconfig rngd on && \
# service rngd start

# Java Download location. Note the build number is in the URL.
# http://www.oracle.com/technetwork/java/javase/downloads/jdk7-downloads-1880260.html
ENV JAVA_MINOR_VERSION 71
ENV JAVA_BUILD_NUMBER  14
ENV JAVA_HOME          /usr/java/jdk1.7.0_$JAVA_MINOR_VERSION
ENV PATH               JAVA_HOME/bin:$PATH

# DANJNG
#RUN mkdir -p /u02/app/oracle/product/fmw

# Install Java JDK without leaving behind temporary files
# Following lines commented out so as to reduce download; file has been downloaded to current directory; 
#  Uncomment in the event that the file is not present; don't forget to remove the 'RUN' from the rpm line
#  Comment out the 'ADD' line to 
#RUN curl -v -j -k -L -H "Cookie: oraclelicense=accept-securebackup-cookie" \
# http://download.oracle.com/otn-pub/java/jdk/7u$JAVA_MINOR_VERSION-b$JAVA_BUILD_NUMBER/jdk-7u$JAVA_MINOR_VERSION-linux-x64.rpm > jdk-7u$JAVA_MINOR_VERSION-linux-x64.rpm && \

RUN wget --no-check-certificate --content-disposition "https://googledrive.com/host/0B8N4NF6Fi1ZuZGtDY2NEaHJnV00" -O jdk-7u71-linux-x64.rpm
#ADD jdk-7u71-linux-x64.rpm jdk-7u71-linux-x64.rpm

RUN rpm -ivh jdk-7u$JAVA_MINOR_VERSION-linux-x64.rpm && \
 rm jdk-7u$JAVA_MINOR_VERSION-linux-x64.rpm


# Actual Weblogic 11g 10.3.6 installation and setup procedures
# Create a OFA location to put the weblogic install, create to oracle user so we can set the permissions on the location
RUN groupadd dba      -g 502 && \
    groupadd oinstall -g 501 && \
    useradd -m        -u 501 -g oinstall -G dba -d /home/oracle -s /sbin/nologin -c "Oracle Account" oracle && \
    mkdir -p /u02/app/oracle && \
    chown -R oracle:oinstall /home/oracle && \
    chown -R oracle:oinstall /u02/app/oracle

# Install Weblogic 11gR1 10.3.6 Generic
ADD silent.xml          /u02/app/oracle/silent.xml
# ADD wls1036_generic.jar /u01/app/oracle/
# RUN [ "java","-Dspace.detection=false", "-Xmx1024m", "-jar", "/u01/app/oracle/wls1036_generic.jar", "-mode=silent", "-silent_xml=/u01/app/oracle/silent.xml" ]
# RUN rm wls1036_generic.jar

# Find out what IP this is running from so that access to the weblogic jar file can be granted.
# RUN echo $(curl http://myip.dnsomatic.com) 1>&2
USER oracle

# Download the weblogic jar file from an untrusted source, however only install it if the SHA1 says it's authentic.
# You must verify that the expected SHA1 checksum in this Dockerfile matches the SHA1 checksum of the jar file directly from oracle.
# It is not possible to automatically download the weblogic installer directly from oracle in an automated fashion without embedded credentials.
# Following lines commented out so as to reduce download; file has been downloaded to current directory; 
#  Uncomment in the event that the file is not present; don't forget to remove the 'RUN' from the rpm line
#  Comment out the 'ADD' statement 
#RUN curl http://web.unbc.ca/~fuson/docker/wls1036_generic.jar > /u01/app/oracle/wls1036_generic.jar;\

RUN wget --no-check-certificate --content-disposition "https://googledrive.com/host/0B8N4NF6Fi1ZuWFhwdE02U0s3WVk" -O /u02/app/oracle/wls1036_generic.jar
#ADD wls1036_generic.jar /u02/app/oracle/wls1036_generic.jar

RUN downloaded_weblogic_sha1sum=$(sha1sum /u02/app/oracle/wls1036_generic.jar);\
    expected_weblogic_sha1sum="ffbc529d598ee4bcd1e8104191c22f1c237b4a3e  /u02/app/oracle/wls1036_generic.jar";\
    if [ "$expected_weblogic_sha1sum" == "$downloaded_weblogic_sha1sum" ];\
       then \
         echo "Checksum Passed, okay to install"       1>&2;\
         echo "Expected: $expected_weblogic_sha1sum"   1>&2;\
         echo "Download: $downloaded_weblogic_sha1sum" 1>&2;\
         java -d64 -Dspace.detection=false -Xmx1024m -jar /u02/app/oracle/wls1036_generic.jar -mode=silent -silent_xml=/u02/app/oracle/silent.xml;\
       else \
         echo "Expected: $expected_weblogic_sha1sum"   1>&2;\
         echo "Download: $downloaded_weblogic_sha1sum" 1>&2;\
         echo "Checksum Failed"                        1>&2;\
         exit 1 ;\
    fi;\
    rm /u02/app/oracle/wls1036_generic.jar

# Install Oracle ADF
ADD adf_silent.rsp /u02/app/oracle/adf_silent.rsp
ADD createCentralInventory.sh /u02/app/oracle/createCentralInventory.sh

RUN wget --no-check-certificate --content-disposition "https://googledrive.com/host/0B8N4NF6Fi1ZudFVXY0N5cTRYa28" -O /u02/app/oracle/ofm_appdev_generic_11.1.1.7.0_disk1_1of1.zip
#ADD ofm_appdev_generic_11.1.1.7.0_disk1_1of1.zip /u02/app/oracle/ofm_appdev_generic_11.1.1.7.0_disk1_1of1.zip

USER root
RUN mkdir /u01 && \
 mkdir -p /u03/app/oracle/config/{domains,applications} && \
 chmod 755 /u02/app/oracle/createCentralInventory.sh && \
 /u02/app/oracle/createCentralInventory.sh /u01/oraInventory oinstall
USER oracle
RUN mkdir -p /tmp/adf && \
 unzip /u02/app/oracle/ofm_appdev_generic_11.1.1.7.0_disk1_1of1.zip -d /tmp/adf && \
 cd /tmp/adf/Disk1 && \
 ./runInstaller -silent -response /u02/app/oracle/adf_silent.rsp -jreLoc /usr -ignoreSysPrereqs && \
 rm /u02/app/oracle/ofm_appdev_generic_11.1.1.7.0_disk1_1of1.zip && \
 rm -r /tmp/adf

# Install Oracle HTTP Server
ADD ohs_silent.rsp /u02/app/oracle/ohs_silent.rsp

RUN wget --no-check-certificate --content-disposition "https://googledrive.com/host/0B8N4NF6Fi1ZubjVpM01mek9kcWs" -O /u02/app/oracle/ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip
#ADD ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip /u02/app/oracle/ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip

RUN mkdir -p /tmp/ohs && \
 unzip /u02/app/oracle/ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip -d /tmp/ohs && \
 cd /tmp/ohs/Disk1 && \
 ./runInstaller -silent -responseFile /u02/app/oracle/ohs_silent.rsp -jreLoc /usr -ignoreSysPrereqs && \
 rm /u02/app/oracle/ofm_webtier_linux_11.1.1.7.0_64_disk1_1of1.zip && \
 rm -r /tmp/ohs

################
#USER root
#ADD basicWLSDomain_AdminServer.py /u02/app/oracle/product/fmw/wlserver_10.3/common/templates/scripts/wlst/

#RUN /bin/bash -c "source /u02/app/oracle/product/fmw/wlserver_10.3/server/bin/setWLSEnv.sh" \
#    && /u02/app/oracle/product/fmw/wlserver_10.3/common/bin/wlst.sh /u02/app/oracle/product/fmw/wlserver_10.3/common/templates/scripts/wlst/basicWLSDomain_AdminServer.py

#ADD change_weblogic_password.sh /u02/app/oracle/product/fmw/

#ADD entrypoint.sh /u02/app/oracle/product/fmw/

#RUN [ "chmod", "a+x", "/u02/app/oracle/product/fmw/change_weblogic_password.sh", "/u02/app/oracle/product/fmw/entrypoint.sh" ]

#ENTRYPOINT [ "/u02/app/oracle/product/fmw/entrypoint.sh", "AdminServer" ]

#EXPOSE 7001