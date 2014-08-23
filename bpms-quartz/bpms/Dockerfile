FROM btison/bpms

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Copy files
ADD ./configure-bpms.sh /configure-bpms.sh
ADD ./env.sh /env.sh
ADD ./configuration /configuration

# Modify script permissions
RUN chmod 755 /configure-bpms.sh

# Install bpms script
RUN /configure-bpms.sh

# Expose port 8080,9990,9999
EXPOSE 8080 9990 9999

ENTRYPOINT ["/bin/bash", "/start-container.sh"]
