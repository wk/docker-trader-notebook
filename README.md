# A Dockerized Jupyter notebook for back-testing in financial markets

## Abstract

This is a docker container based on the [data science notebook](https://github.com/jupyter/docker-stacks/tree/master/datascience-notebook) of [Project Jupyter](https://jupyter.org/).

It includes additional components that are useful for financial market back-testing, as well as data acquisition through the APIs made available by [Interactive Brokers](https://www.interactivebrokers.com/).

Some of the components included:
* IB TWS
    * [ib_insync](https://github.com/erdewit/ib_insync)
    * [twsapi](https://interactivebrokers.github.io/)
* Backtesting
    * [backtrader](https://www.backtrader.com/)
* Plotting
    * [bqplot](https://github.com/bloomberg/bqplot)
    * [datashader](https://github.com/pyviz/datashader)
    * [ggplot](http://http://ggplot.yhathq.com/)
    * [holoviews](https://github.com/pyviz/holoviews)
    * [mpld3](https://github.com/mpld3/mpld3)
    * [plotly](https://plot.ly/), with [chart-studio](https://plotly.com/chart-studio/) and [cufflinks](https://github.com/santosjorge/cufflinks)
* Natural Language Processing
    * [nltk](https://github.com/nltk/nltk)
* Machine Learning
    * [TensorFlow](https://www.tensorflow.org/)
* Misc
    * lxml, html5lib for pandas html_read
    * [pandas-datareader](https://github.com/pydata/pandas-datareader)

Components can added or removed by modifying the `additional-requirements-conda.txt` and `additional-requirements-pip.txt` files prior to building the image.

*Due to licensing restrictions, this container is only made available as a Dockerfile to be built by the end user, and not as a ready-to-run pre-built container.*

## Basic usage

Begin by checking out the Dockerfile and building the container:

```shell
git clone https://github.com/wk/docker-trader-notebook.git
sudo docker build -t trader-notebook docker-trader-notebook
```

For runtime parameters, see Jupyter's [docker-stacks](https://github.com/jupyter/docker-stacks/tree/master/).
