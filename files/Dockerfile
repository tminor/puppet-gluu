FROM centos:8

USER root

RUN yum install -y gem

RUN yum install ruby -y

RUN gem install puppet

RUN mkdir -p /etc/puppetlabs/code/modules

RUN yum install -y wget curl
RUN wget https://repo.gluu.org/rhel/Gluu-rhel-8-testing.repo -O /etc/yum.repos.d/Gluu.repo
RUN wget https://repo.gluu.org/rhel/RPM-GPG-KEY-GLUU -O /etc/pki/rpm-gpg/RPM-GPG-KEY-GLUU
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-GLUU
RUN yum install -y systemd

RUN yum install -y gluu-server

RUN puppet module install puppetlabs/stdlib
RUN yum install -y zip openssh
RUN unzip /opt/gluu-server/opt/dist/gluu/community-edition-setup.zip
RUN cp -R ./community-edition-setup-version_*/* /opt/gluu-server/install/community-edition-setup/
RUN dnf install -y make gcc rpm-build ruby-devel
RUN gem install pry -v 0.12.2
RUN gem install jwt httparty net-ldap nokogiri nori gyoku pry-nav pry-remote zeitwerk ruby-saml

CMD ["/usr/sbin/init"]