# -- stage 1: build a wheel of twsapi for python, as ib_insync requires it
FROM ubuntu:bionic-20190612@sha256:9b1702dcfe32c873a770a32cfd306dd7fc1c4fd134adfb783db68defc8894b3c as twsapi-build

RUN apt-get -yq update && \
    apt-get -yq install python3 python3-setuptools python3-wheel unzip

WORKDIR /tmp/twsapi-build

# build twsapi for python
# Subject to licensing conditions at http://interactivebrokers.github.io/
ADD http://interactivebrokers.github.io/downloads/twsapi_macunix.976.01.zip .
RUN unzip twsapi_macunix.976.01.zip
WORKDIR /tmp/twsapi-build/IBJts/source/pythonclient
RUN python3 setup.py bdist_wheel

# -- stage 2: build the trader notebook
FROM jupyter/datascience-notebook:latest

USER $NB_USER

# Update anaconda before we continue
# RUN conda update -n base conda
# RUN conda update --all

# pip installs
# bokeh, scikit-learn, tqdm are all part of jupyter/datascience-notebook
# Additional visualization and plotting packages
RUN pip install ggplot plotly bqplot mpld3
# Additional financial markets packages
RUN pip install backtrader ib_insync

# Additional work
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager
RUN jupyter labextension install bqplot

# Install zipline via conda then ingest zipline quantopian-quandl metadata bundle
# RUN conda install -c Quantopian zipline
# RUN zipline ingest -b quantopian-quandl

# install twsapi from stage 1
COPY --from=twsapi-build \
    /tmp/twsapi-build/IBJts/source/pythonclient/dist/ibapi-9.76.1-py3-none-any.whl \
    /tmp/
RUN pip install /tmp/ibapi-9.76.1-py3-none-any.whl

