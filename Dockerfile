ARG IMAGE=intersystemsdc/iris-community:latest
FROM $IMAGE AS builder

WORKDIR /home/irisowner/dev

ARG TESTS=0
ARG MODULE="dc-sample"
ARG NAMESPACE="TOOL"

ENV IRISUSERNAME "_SYSTEM"
ENV IRISPASSWORD "SYS"
ENV IRISNAMESPACE $NAMESPACE
ENV PYTHON_PATH=/usr/irissys/bin/
ENV PATH "/usr/irissys/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/irisowner/bin"

COPY requirements.txt /home/irisowner/dev/requirements.txt

RUN --mount=type=bind,src=.,dst=. \
    pip3 install -r requirements.txt && \
    iris start IRIS && \
    iris session IRIS < iris.script && \
    iris stop IRIS quietly

FROM $IMAGE AS final

# Copia script de sincronização de dados
ADD --chown=${ISC_PACKAGE_MGRUSER}:${ISC_PACKAGE_IRISGROUP} https://github.com/grongierisc/iris-docker-multi-stage-script/releases/latest/download/copy-data.py /home/irisowner/dev/copy-data.py

# Copia o .iris_init se for necessário manter aliases
COPY .iris_init /home/irisowner/.iris_init

RUN --mount=type=bind,source=/,target=/builder/root,from=builder \
    cp -f /builder/root/usr/irissys/iris.cpf /usr/irissys/iris.cpf && \
    python3 /home/irisowner/dev/copy-data.py -c /usr/irissys/iris.cpf -d /builder/root/
