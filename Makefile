PROJECT = webhooks
include erlang.mk

qc:
	rebar co skip_deps=true

run:
	erl -pa ebin -pa deps/*/ebin -eval 'application:ensure_all_started(webhooks).'
