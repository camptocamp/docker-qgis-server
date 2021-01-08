FROM camptocamp/c2cwsgiutils:3

RUN mkdir -p /tmp/junitxml

COPY . /acceptance_tests/

ENV DOCKER_RUN 1
WORKDIR /acceptance_tests

CMD sleep infinity
