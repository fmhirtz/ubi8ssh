FROM ubi8/ubi8:latest

ARG ADMIN_PUBLIC_KEY

RUN yum -y install openssh-server ed openssh-clients tlog glibc-langpack-en && yum clean all && systemctl enable sshd;
RUN sed -i 's/#Port.*$/Port 2022/' /etc/ssh/sshd_config && chmod 775 /var/run && rm -f /var/run/nologin
RUN mkdir /etc/systemd/system/sshd.service.d/ && echo -e '[Service]\nRestart=always' > /etc/systemd/system/sshd.service.d/sshd.conf

#COPY tlog-rec-session.conf /etc/tlog/tlog-rec-session.conf
RUN adduser --system -s /bin/bash -u 1001 fmhirtz && \ #UID matching user uid on host
           mkdir -p /home/fmhirtz/.ssh 

RUN touch /home/fmhirtz/.ssh/authorized_keys \
           chmod 700 /home/fmhirtz/.ssh  && \
           chmod 600 /home/fmhirtz/.ssh/authorized_keys && \
           sed -i 's/1001/0/g' /etc/passwd && \ #Update UID with root UID
           echo ${ADMIN_PUBLIC_KEY} >> /home/fmhirtz/.ssh/authorized_keys && \
           chown -R fmhirtz:fmhirtz /home/fmhirtz
LABEL Description="Containerized ssh server"
EXPOSE 2022

CMD ["/sbin/init"]

