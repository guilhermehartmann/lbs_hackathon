FROM     ubuntu
MAINTAINER Guilherme Hartmann "guilhermehartmann@gmail.com"

# Usage:
# docker build --rm -t nginx .
# docker run -d -P -t nginx

# Import context
ADD ./context /tmp/context

# make sure the package repository is up to date
RUN apt-get update

# install sshd
RUN apt-get install -y openssh-server vim
RUN mkdir /var/run/sshd

# Adding supervisord
RUN apt-get install -y supervisor 

# Adding nginx
RUN apt-get install -y build-essential git
RUN apt-get install -y python python-dev python-setuptools python-pip
RUN apt-get install -y nginx 

RUN pip install uwsgi

# create user and setup sudo / keys
RUN adduser --shell /bin/bash --gecos 'debian repository dedicated user' --uid 5000 --disabled-password --home /home/hackathon hackathon
RUN cp /tmp/context/etc/sudoers /etc/sudoers
RUN cp -R /tmp/context/home/hackathon/ /home/
RUN cp -R /tmp/context/home/hackathon/.ssh /home/hackathon
RUN chown -R hackathon:hackathon /home/hackathon

# Adding packages required by the WebApp
RUN pip install -r /home/hackathon/cfg/requirements.txt

# Adding sites
RUN rm -rf /etc/nginx/sites-enabled
RUN cp -R /tmp/context/etc/nginx/sites-enabled /etc/nginx/

# Adding supervisord
RUN cp /tmp/context/etc/supervisor/conf.d/supervisord.conf /etc/supervisor/conf.d/supervisord.conf 

# expose ports
EXPOSE 80
EXPOSE 22

CMD ["/usr/bin/supervisord"]
