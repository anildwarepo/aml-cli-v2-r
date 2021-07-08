FROM rocker/tidyverse:4.0.0-ubuntu18.04
 
# Install python (this is still required by AzureML, but this requirement will soon be removed )
RUN apt-get update -qq && \
 apt-get install -y python3-pip
RUN ln -f /usr/bin/python3 /usr/bin/python
RUN ln -f /usr/bin/pip3 /usr/bin/pip
RUN pip install -U pip

RUN wget https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb
RUN sudo dpkg -i packages-microsoft-prod.deb
RUN sudo apt-get update

# install azureml-base and libfuse (this is required for data access in local execution -- this requirement will also be removed soon)
RUN sudo apt-get install -y libfuse-dev libxml2-dev
RUN pip install azureml-dataprep azureml-core

RUN mkdir /adlsgen2store
RUN chmod 777 /adlsgen2store
#COPY src/r1.env /adlsgen2store

# Install additional R packages 
RUN R -e "install.packages(c('optparse'), repos = 'https://cloud.r-project.org/')"
RUN R -e "install.packages(c('AzureStor'), repos = 'https://cloud.r-project.org/')"
RUN R -e "install.packages(c('AzureAuth'), repos = 'https://cloud.r-project.org/')"

