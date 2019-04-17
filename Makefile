# GNU Makefile for Django CMS stack project 

-include .env

DOMAIN ?= example.com
SERVICE ?= $(DOMAIN:.=_)

FACILITY ?= cms
DC ?= docker-compose
TARGET ?= dev


# use revision hash as build tag
TAG ?= $(shell git status 2>&1 >/dev/null && git rev-parse --short HEAD)

ifeq ("$(shell test -e config/compose/$(TARGET).yml && echo y)","y")
  COMPOSE_FILE = docker-compose.yml:config/compose/$(TARGET).yml
endif

DB_DUMP ?= $(SERVICE)-$(FACILITY)-db.sql.gz
DB_DUMP_URL = https://s3.amazonaws.com/$(SERVICE)-prod-db/$(DB_DUMP)

INTERIM_DB ?= interim
PSQL_ARGS ?= -h db -U postgres


-include config/env/common.env

-include config/env/$(TARGET).env
-include config/mk/swarm.mk

export

up: dev-srv

# Start development server
dev-srv: TARGET=dev
dev-srv: dc-up

dc-%:
	$(DC) $* $(A)

	
build: dc-build

mig:
	$(MAKE) dc-run A='migrate'

sh:
	$(MAKE) dc-run A='web bash'

reset-db:
	$(MAKE) dc-run A='web python manage.py reset_db --noinput'

$(DB_DUMP):
	curl -o $@ $(DB_DUMP_URL)
	
restoredb: $(DB_DUMP)
	dropdb --if-exists $(PSQL_ARGS) $(INTERIM_DB)
	createdb $(PSQL_ARGS) $(INTERIM_DB)
	zcat  $(DB_DUMP) | psql $(PSQL_ARGS) -d $(INTERIM_DB) 
	psql $(PSQL_ARGS) -d template1 < scripts/restoredb.sql

dj-%:
	python manage.py $* --noinput $(A)

req:
	pip install -r requirements.txt
	
freeze-req:
	pip freeze > requirements-frozen.txt 

srv:
	uwsgi --yaml config/uwsgi.yml

.env: sample.env
	cp sample.env .env
	echo "Customize .env"
	exit -1

clean:
	sudo find . -name '*.pyc' -o -name '*.pyo' -o -name '__pycache__' -exec rm -rf {} \;

