FROM python:3.10.7-slim-bullseye as base
ARG DBT_VERSION=1.0.0
RUN apt-get update  \
        && apt-get dist-upgrade -y  \
        && apt-get install -y --no-install-recommends git ssh-client software-properties-common make build-essential ca-certificates libpq-dev  \
        && apt-get clean  \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
RUN python -m pip install "git+https://github.com/dbt-labs/dbt-core@v${DBT_VERSION}#egg=dbt-postgres&subdirectory=plugins/postgres" --no-cache-dir
RUN python -m pip install "git+https://github.com/dbt-labs/dbt-redshift@v${DBT_VERSION}#egg=dbt-redshift" --no-cache-dir
RUN python -m pip install "git+https://github.com/dbt-labs/dbt-bigquery@v${DBT_VERSION}#egg=dbt-bigquery" --no-cache-dir
RUN python -m pip install "git+https://github.com/dbt-labs/dbt-snowflake@v${DBT_VERSION}#egg=dbt-snowflake" --no-cache-dir
RUN python -m pip install "git+https://github.com/dbt-labs/dbt-core@v${DBT_VERSION}#egg=dbt-core&subdirectory=core" --no-cache-dir
WORKDIR /usr/app/dbt/
ENTRYPOINT ["dbt"]