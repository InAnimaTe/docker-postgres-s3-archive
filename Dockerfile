FROM postgres:latest

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y curl

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python
RUN pip install awscli

ADD run /app/run
RUN chmod +x /app/run

CMD ["/app/run.sh"]
