# -- stage 1: build a wheel of twsapi for python, as ib_insync requires it
FROM ubuntu:bionic-20190612@sha256:9b1702dcfe32c873a770a32cfd306dd7fc1c4fd134adfb783db68defc8894b3c as twsapi-build

RUN apt-get -yq update && \
    apt-get -yq install python3 python3-setuptools python3-wheel unzip

WORKDIR /tmp/twsapi-build

# build twsapi for python
# Subject to licensing conditions at http://interactivebrokers.github.io/
ADD http://interactivebrokers.github.io/downloads/twsapi_macunix.979.01.zip .
RUN unzip twsapi_macunix.979.01.zip
WORKDIR /tmp/twsapi-build/IBJts/source/pythonclient
RUN python3 setup.py bdist_wheel

# -- stage 2: build the trader notebook
FROM jupyter/datascience-notebook:latest

USER $NB_USER

# Update anaconda before we continue
# RUN conda update -n base conda
# RUN conda update --all

# bokeh, scikit-learn, tqdm are all part of jupyter/datascience-notebook

# conda installs (plotly, bqplot, mpld3, html5lib, lxml, phanomjs, 
#                 selenium, colorcet, datashader, holoviews, hvplot,
#                 flask)
COPY additional-requirements-conda.txt /tmp/
RUN conda install --yes --file /tmp/additional-requirements-conda.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# pip installs (ggplot, backtrader, ib_insync)
COPY additional-requirements-pip.txt /tmp/
RUN pip install --requirement /tmp/additional-requirements-pip.txt && \
    fix-permissions $CONDA_DIR && \
    fix-permissions /home/$NB_USER

# Jupyter lab extensions 
RUN jupyter labextension install bqplot --no-build
RUN jupyter labextension install @pyviz/jupyterlab_pyviz --no-build
RUN jupyter labextension install jupyterlab-plotly@4.9.0 --no-build
RUN jupyter labextension install @jupyter-widgets/jupyterlab-manager plotlywidget@4.9.0 --no-build

# Build all jupyter lab extensions at once
RUN jupyter lab build

# Install zipline and pyfolio via conda then ingest zipline quantopian-quandl metadata bundle
# RUN conda install -c Quantopian install zipline pyfolio
# RUN zipline ingest -b quantopian-quandl

# install twsapi from stage 1
COPY --from=twsapi-build \
    /tmp/twsapi-build/IBJts/source/pythonclient/dist/ibapi-9.79.1-py3-none-any.whl \
    /tmp/
RUN pip install /tmp/ibapi-9.79.1-py3-none-any.whl

