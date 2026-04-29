IMAGE = ocaml/opam:ubuntu-22.04-ocaml-5.5
NAME = ocaml-piscine
USER = ${shell whoami}
VOLUME_PATH = /home/${USER}/Desktop/42-piscine-ocaml

YELLOW = "\e[0;33m"
RESET = "\e[0m"

all: pull run

pull:
	docker pull ${IMAGE}

run:
	@echo ${YELLOW} "The ${VOLUME_PATH} folder needs to have "
	@echo "read, write and execute access for the 'Others', use: \n"
	@echo "chmod -R 757 ${VOLUME_PATH}\n\n" ${RESET}
	docker run -it --rm \
	-v ${VOLUME_PATH}:/home/opam/piscine \
	-w /home/opam/piscine \
	--name ${NAME} \
	${IMAGE}

clean:
	docker image rm ${IMAGE}

.PHONY: all pull run clean