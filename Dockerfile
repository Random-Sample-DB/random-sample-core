
# example Dockerfile for https://docs.docker.com/engine/examples/postgresql_service/
FROM jupyter/scipy-notebook

ARG DEBIAN_FRONTEND=noninteractive
USER root
RUN sudo mkdir /var/lib/apt/lists/partial
RUN sudo apt-get update
RUN apt-get install -y gnupg

# RUN apt-get -y upgrade
# RUN apt-get install -y build-essential python-dev
# RUN apt-get install -y python python-distribute python-pip
# RUN pip install pip --upgrade

RUN apt-get install -yq tzdata
RUN apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y software-properties-common postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3
USER postgres
# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/9.3/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/9.3/main/postgresql.conf
RUN echo "port = 1486" >> /etc/postgresql/9.3/main/postgresql.conf

USER root
RUN echo " #!/bin/bash" >> work/jupyter.sh
RUN echo "jupyter notebook --allow-root --no-browser --ip 0.0.0.0 --port 8050 ." >> work/jupyter.sh


# Expose the PostgreSQL port
EXPOSE 1486

# Add VOLUMEs to allow backup of config, logs and databases
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

USER postgres
# Set the default command to run when starting the container
CMD ["/usr/lib/postgresql/9.3/bin/postgres", "-D", "/var/lib/postgresql/9.3/main", "-c", "config_file=/etc/postgresql/9.3/main/postgresql.conf"]