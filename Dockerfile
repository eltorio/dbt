FROM python:3.10-bookworm as base
ARG DBT_VERSION=1.0.0
ARG NODE_MAJOR="20"
RUN apt-get update  \
      && apt-get dist-upgrade -y  \
      && apt-get install -y --no-install-recommends git ssh-client software-properties-common make build-essential ca-certificates curl cmake\
      && mkdir -p /etc/apt/keyrings \
      && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
      && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
      && wget https://apache.jfrog.io/artifactory/arrow/$(lsb_release --id --short | tr 'A-Z' 'a-z')/apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
      && apt install -y -V ./apache-arrow-apt-source-latest-$(lsb_release --codename --short).deb \
      && rm ./apache-arrow-apt-source-latest* \
      && apt-get update \
      && apt-get install nodejs libarrow-dev -y \
      && apt-get clean  \
      && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
COPY dbt-extractor /tmp/dbt-extractor
RUN python3.10 -m pip install --upgrade pip
RUN cd /tmp/dbt-extractor \
      && . $HOME/.cargo/env \
      && cargo build -r \
      && python3.10 -m pip install . \
      && cd / \
      && rm -rf /tmp/dbt-extractor
RUN . $HOME/.cargo/env && python3.10 -m pip install "git+https://github.com/dbt-labs/dbt-core@v${DBT_VERSION}#egg=dbt-core&subdirectory=core" --no-cache-dir
RUN . $HOME/.cargo/env && python3.10 -m pip install "git+https://github.com/dbt-labs/dbt-core@v${DBT_VERSION}#egg=dbt-postgres&subdirectory=plugins/postgres" --no-cache-dir
RUN . $HOME/.cargo/env && python3.10 -m pip install "git+https://github.com/dbt-labs/dbt-redshift@v${DBT_VERSION}#egg=dbt-redshift" --no-cache-dir
RUN . $HOME/.cargo/env && python3.10 -m pip install "git+https://github.com/dbt-labs/dbt-bigquery@v${DBT_VERSION}#egg=dbt-bigquery" --no-cache-dir
RUN . $HOME/.cargo/env && python3.10 -m pip install "git+https://github.com/dbt-labs/dbt-snowflake@v${DBT_VERSION}#egg=dbt-snowflake" --no-cache-dir
RUN . $HOME/.cargo/env && python3.10 -m pip install markupsafe==2.0.1 pytz
WORKDIR /usr/app/dbt/
ENTRYPOINT ["dbt"]
# ENTRYPOINT ["/bin/bash"]