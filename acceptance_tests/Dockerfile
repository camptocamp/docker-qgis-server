FROM python:3.10.5

RUN mkdir -p /tmp/junitxml

COPY requirements.txt /tmp/
RUN python3 -m pip install --disable-pip-version-check --no-cache-dir --requirement=/tmp/requirements.txt \
    && rm --recursive --force /tmp/*

WORKDIR /acceptance_tests

COPY Pipfile Pipfile.lock ./
RUN pipenv sync --system --clear --dev \
    && rm --recursive --force /usr/local/lib/python3.*/dist-packages/tests/ /tmp/* /root/.cache/*

COPY . ./

ENV DOCKER_RUN 1

CMD ["sleep", "infinity"]
