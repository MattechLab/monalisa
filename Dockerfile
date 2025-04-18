# This Dockerfile is modification of https://github.com/mathworks-ref-arch/matlab-dockerfile (Copyright 2019-2024 The MathWorks, Inc.)
# There is a flexibility in the way the image is build and you can edit parameters according to your needs.
# Since it's matlab, you need at least a license to run it locally
# You need to have access to a matlab license server if you want to run this in a non interactive fashion (e.g. on clusters running SLURM without interaction)
# Here is an example docker build command with the optional build arguments.
# docker build --build-arg MATLAB_RELEASE=r2024a 
#              --build-arg MATLAB_PRODUCT_LIST="MATLAB Deep_Learning_Toolbox Symbolic_Math_Toolbox"
#              --build-arg MATLAB_INSTALL_LOCATION="/opt/matlab/R2024a"
#              --build-arg LICENSE_SERVER=12345@hostname.com 
#              -t my_matlab_image_name .

# To specify which MATLAB release to install in the container, edit the value of the MATLAB_RELEASE argument.
# Use lowercase to specify the release, for example: ARG MATLAB_RELEASE=r2021b
# Note the matlab version should be matching the license server last update.

## SUGGESTED USE:
# sudo docker build --build-arg LICENSE_SERVER=port@servername  -t my_matlab_image_name .
# Optionally you can add (--platform linux/amd64 to specify your platform) (--progress=plain for debug logging)
# sudo docker run --init --rm  my_matlab_image_name

## Default parameters, note this is the minimal set of toolboxes to run monalisa
ARG MATLAB_RELEASE=r2024a

# Specify the list of products to install into MATLAB.
ARG MATLAB_PRODUCT_LIST="MATLAB Statistics_and_Machine_Learning_Toolbox"



# Specify MATLAB Install Location.
ARG MATLAB_INSTALL_LOCATION="/opt/matlab/${MATLAB_RELEASE}"

# Specify license server information using the format: port@hostname 
ARG LICENSE_SERVER

# When you start the build stage, this Dockerfile by default uses the Ubuntu-based matlab-deps image.
# To check the available matlab-deps images, see: https://hub.docker.com/r/mathworks/matlab-deps
FROM mathworks/matlab-deps:latest

# Declare build arguments to use at the current build stage.
ARG MATLAB_RELEASE
ARG MATLAB_PRODUCT_LIST
ARG MATLAB_INSTALL_LOCATION
ARG LICENSE_SERVER
ARG OUTPUT_DIR="/usr/src/app/output"

# Install mpm dependencies.
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    wget \
    unzip \
    ca-certificates \
    g++ \
    git \
    expect \
    libgtk2.0-0 \
    build-essential \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Add "matlab" user and grant sudo permission.
RUN adduser --shell /bin/bash --disabled-password --gecos "" matlab \
    && echo "matlab ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/matlab \
    && chmod 0440 /etc/sudoers.d/matlab

# Set user and work directory.
# USER root
# RUN apt-get update && apt-get install -y libgtk2.0-0 build-essential

USER matlab
WORKDIR /home/matlab

# Run mpm to install MATLAB in the target location and delete the mpm installation afterwards.
# If mpm fails to install successfully, then print the logfile in the terminal, otherwise clean up.
# Pass in $HOME variable to install support packages into the user's HOME folder.
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \ 
    && chmod +x mpm \
    && sudo HOME=${HOME} ./mpm install \
    --release=${MATLAB_RELEASE} \
    --destination=${MATLAB_INSTALL_LOCATION} \
    --products ${MATLAB_PRODUCT_LIST} \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && sudo rm -rf mpm /tmp/mathworks_root.log \
    && sudo ln -s ${MATLAB_INSTALL_LOCATION}/bin/matlab /usr/local/bin/matlab
# wanted to remove the `sudo` above, but error about permission occurred, so added them back
# Note: Uncomment one of the following two ways to configure the license server.

# Option 1. Specify the host and port of the machine that serves the network licenses
# if you want to store the license information in an environment variable. This
# is the preferred option. You can either use a build variable, like this: 
# --build-arg LICENSE_SERVER=27000@MyServerName or you can specify the license server 
# directly using: ENV MLM_LICENSE_FILE=27000@flexlm-server-name
ENV MLM_LICENSE_FILE=$LICENSE_SERVER

# Option 2. Alternatively, you can put a license file into the container.
# Enter the details of the license server in this file and uncomment the following line.
# COPY network.lic ${MATLAB_INSTALL_LOCATION}/licenses/

# The following environment variables allow MathWorks to understand how this MathWorks 
# product (MATLAB Dockerfile) is being used. This information helps us make MATLAB even better. 
# Your content, and information about the content within your files, is not shared with MathWorks. 
# To opt out of this service, delete the environment variables defined in the following line. 
# To learn more, see the Help Make MATLAB Even Better section in the accompanying README: 
# https://github.com/mathworks-ref-arch/matlab-dockerfile#help-make-matlab-even-better
ENV MW_DDUX_FORCE_ENABLE=true MW_CONTEXT_TAGS=MATLAB:DOCKERFILE:V1

# Set the working directory inside the container
WORKDIR /usr/src/app
# Copy the entire local monalisa directory into the container
COPY . /usr/src/app

# Yiwei: add this line for changing the permission.
USER root 
RUN chmod -R ugo+x /usr/src/app

# Set the working directory to the folder containing your script
WORKDIR /usr/src/app/examples/scripts
# DEBUG LOGGING: Check if the directory /usr/src/app/src/bmFourierN exists
RUN if [ -d "/usr/src/app/src/bmFourierN" ]; then \
        echo "Directory /usr/src/app/src/bmFourierN exists"; \
    else \
        echo "Directory /usr/src/app/src/bmFourierN does not exist"; \
        exit 1; \
    fi

ENTRYPOINT ["matlab"]

# I am using root otherwise I encountered permission errors, not sure it's safe (INITIAL)
# Yiwei: comment it, avoid root permission...
USER root 
# Compile c++ code
CMD ["matlab", "-batch", "testDocker"]
