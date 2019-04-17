FROM python:3.7

RUN apt-get update -yy && apt-get install -y postgresql-client && apt-get clean -y
COPY requirements-frozen.txt /requirements.txt
RUN pip install -r /requirements.txt

COPY ./config/entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh

COPY . /app
WORKDIR /app

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]

