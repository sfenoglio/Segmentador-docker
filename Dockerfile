FROM ubuntu:18.04
MAINTAINER Sebastián Fenoglio <sfenoglio@gmail.com>

ENV python_env="/python_env"

# timezone
ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

#=============================
# INSTALL BASE PACKAGES
#=============================

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update && apt-get install -y --no-install-recommends \
      build-essential \
      pkg-config \
      gfortran \
      libatlas-base-dev \
      libatlas3-base \
      fonts-lyx \
      libfreetype6-dev \
      libpng-dev \
      python3.6 \
      python3.6-dev \
      python3-pip \
      python3-tk \
      tk-dev && \
    rm -rf /var/lib/apt/lists/*

#=============================
# INSTALL PYTHON PACKAGES
#=============================
RUN pip3 install -U virtualenv==16.6.0
RUN virtualenv ${python_env}

COPY install_python_module /usr/local/bin/
RUN chmod -R o+rwx /usr/local/bin/
RUN install_python_module pip==18.0.0
RUN install_python_module numpy==1.15.2
RUN install_python_module opencv-python==3.4.2.17
RUN install_python_module opencv-contrib-python==3.4.2.17
RUN install_python_module scikit-image==0.14.0
RUN install_python_module scikit-learn==0.20.0
RUN install_python_module torch==1.1.0
RUN install_python_module torchvision==0.2.1

RUN ln -s ${python_env}/bin/python /usr/local/bin/python


# Create a new user "developer".
# It will get access to the X11 session in the host computer

ENV uid=1000
ENV gid=${uid}

COPY init.sh /
COPY create_user.sh /
COPY matplotlibrc_tkagg /
COPY matplotlibrc_agg /

RUN chmod +x /init.sh
RUN chmod +x /create_user.sh

ENTRYPOINT ["/init.sh"]
CMD ["/create_user.sh"]
