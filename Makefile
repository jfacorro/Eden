PROJECT=Eden

all: deps app protocols

get-deps:
	rm -f mix.lock
	mix deps.get

deps: get-deps
	mix deps.compile

app:
	mix compile

protocols:
	mix compile.protocols

clean-deps:
	mix deps.clean --all
	rm -rf deps

clean: clean-deps
	mix clean

test: app
	mix test

shell: app
	iex --name ${PROJECT}@`hostname` -pa _build/dev/consolidated -S mix

escript:
	mix escript.build

docs:
	MIX_ENV=docs mix docs

publish:
	mix hex.publish
	MIX_ENV=docs mix hex.docs
