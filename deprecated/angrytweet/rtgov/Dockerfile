FROM btison/rtgov

MAINTAINER Bernard Tison <bernard.tison@gmail.com>

# Scripts and resources
ADD ./deploy-angrytweet.sh /deploy-angrytweet.sh
ADD ./env.sh /env.sh
ADD ./resources /resources

# Modify script permissions
RUN chmod 755 /deploy-angrytweet.sh

# Deploy Angrytweet application
RUN /deploy-angrytweet.sh

# Entrypoint
ENTRYPOINT ["/bin/bash", "/start-container.sh"]
