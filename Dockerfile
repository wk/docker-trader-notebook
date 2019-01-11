# -- stage 1: build a wheel of twsapi for python, as ib_insync requires it
FROM ubuntu:bionic-20180526@sha256:c8c275751219dadad8fa56b3ac41ca6cb22219ff117ca98fe82b42f24e1ba64e as twsapi-build

RUN apt-get -yq update && \
    apt-get -yq install python3 python3-setuptools python3-wheel unzip

WORKDIR /tmp/twsapi-build

# build twsapi for python
# Subject to licensing conditions at http://interactivebrokers.github.io/
ADD http://interactivebrokers.github.io/downloads/twsapi_macunix.974.01.zip .
RUN unzip twsapi_macunix.974.01.zip
WORKDIR /tmp/twsapi-build/IBJts/source/pythonclient
RUN python3 setup.py bdist_wheel

# -- stage 2: build the trader notebook
FROM jupyter/datascience-notebook:latest

USER $NB_USER

# pip installs
RUN pip install zipline backtrader ib_insync jupyter_dashboards ggplot plotly

# Ingest zipline quantopian-quandl metadata bundle
RUN zipline ingest -b quantopian-quandl

# install twsapi from stage 1
# in IB API 9.74.01, the pythonclient version remains tagged as 9.73.7
COPY --from=twsapi-build \
    /tmp/twsapi-build/IBJts/source/pythonclient/dist/ibapi-9.73.7-py3-none-any.whl \
    /tmp/
RUN pip install /tmp/ibapi-9.73.7-py3-none-any.whl

