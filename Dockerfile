# -- stage 1: build a wheel of twsapi for python, as ib_insync requires it
FROM ubuntu:xenial as twsapi-build

RUN apt-get -yq update && \
    apt-get -yq install python3 python3-setuptools python3-wheel unzip

WORKDIR /tmp/twsapi-build

# build twsapi for python
# Subject to licensing conditions at http://interactivebrokers.github.io/
ADD http://interactivebrokers.github.io/downloads/twsapi_macunix.973.07.zip .
RUN unzip twsapi_macunix.973.07.zip
WORKDIR /tmp/twsapi-build/IBJts/source/pythonclient
RUN python3 setup.py bdist_wheel

# -- stage 2: build the trader notebook
FROM jupyter/datascience-notebook:latest

USER $NB_USER

# pip installs
RUN pip install zipline backtrader ib_insync jupyter_dashboards ggplot plotly spacy

# Ingest zipline quantopian-quandl metadata bundle
RUN zipline ingest -b quantopian-quandl

# Download spacy english language data
RUN python3 -m spacy download en

# install twsapi from stage 1
COPY --from=twsapi-build \
    /tmp/twsapi-build/IBJts/source/pythonclient/dist/ibapi-9.73.7-py3-none-any.whl \
    /tmp/
RUN pip install /tmp/ibapi-9.73.7-py3-none-any.whl

