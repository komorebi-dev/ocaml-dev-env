IMAGE = ocaml/opam:alpine-3.23-ocaml-4.12
NAME = ocaml-piscine

all: pull run

pull:
	docker pull ${IMAGE}

run:
	docker run -it -v ${PWD}:/home/opam/piscine -w /home/opam/piscine --rm ${IMAGE}

clean:
	docker image rm ${IMAGE}

.PHONY: all pull run clean