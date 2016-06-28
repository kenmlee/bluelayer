############################################################
# Dockerfile to build SoftLayer Slick portal images
# Based on Ubuntu
############################################################

# Set the base image to Ubuntu
FROM ubuntu:14.04

# File Author / Maintainer
MAINTAINER Ronan Dalton

################## BEGIN INSTALLATION ######################

# Update the repository sources list & install pre-req packages
RUN apt-get update && apt-get install -y \
libpq-dev sqlite3 \
python-pip git \
python-dev wget \
libjpeg-dev \
&& rm -rf /var/lib/apt/lists/*

#Install pre-reqs & SoftLayer Python Bindings
RUN pip install WTForms wtforms-html5 WTForms-Components
RUN pip install flask
RUN pip install six --upgrade
RUN pip install https://pypi.python.org/packages/source/F/Flask-Login/Flask-Login-0.2.10.tar.gz 
RUN pip install https://github.com/softlayer/softlayer-python/archive/v3.3.1.tar.gz

#Get the Slick code 
RUN mkdir -p /usr/local/slick 
RUN ["git", "clone", "https://github.com/softlayer/slick.git", "/usr/local/slick"]

#Install 
RUN ["python", "/usr/local/slick/setup.py", "install"] 

#Setup the Slick database
RUN cd /usr/local/slick; alembic upgrade head

#Configure the environment 
COPY config.py /usr/local/slick/config.py
ENV SLICK_CONFIG_FILE /usr/local/slick/config.py 

##################### INSTALLATION END #####################

# Expose the default port
EXPOSE 5000

# Default port to execute the entrypoint (MongoDB)
CMD ["--port 5000"]

# Set default container command
ENTRYPOINT python /usr/local/slick/run.py
