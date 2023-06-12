FROM centos:7

ENV DEBIAN_FRONTEND=noninteractive

RUN yum -y update --nogpgcheck && \
    yum -y install epel-release && \
    yum -y install httpd \
                   php \
                   php-mysql \
                   mysql \
                   mysql-server

COPY genStudent.sh /home/genStudent.sh
COPY feeBreakup.sh /home/feeBreakup.sh
COPY office_messAllocation.sh /home/office_messAllocation.sh
COPY permit.sh /home/permit.sh
COPY student_messAllocation.sh /home/student_messAllocation.sh
COPY studentDetails.txt /home/studentDetails.txt
COPY updateDefaulter.sh /home/updateDefaulter.sh
COPY README.md /home/README.md
COPY gamma-z.hm.conf /etc/httpd/conf.d/gamma-z.hm.conf

RUN echo "ServerName gamma-z.hm" >> /etc/httpd/conf/httpd.conf
RUN mkdir -p /var/www/gamma-z.hm/public_html

COPY index.php /var/www/gamma-z.hm/public_html/index.php

RUN chown -R apache:apache /var/www/gamma-z.hm/public_html
RUN chmod -R 755 /var/www

EXPOSE 80

CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]
