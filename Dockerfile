# source of template: https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/alternates/building-on-matlab-docker-image/Dockerfile
# Specify the extra products to install into the image. These products can either be toolboxes or support packages.
ARG ADDITIONAL_PRODUCTS="Statistics_and_Machine_Learning_Toolbox"

# Use the Matlab Docker image as the base image
FROM mathworks/matlab:r2024a

# By default, the MATLAB container runs as user "matlab". To install mpm dependencies, switch to root.
USER root

# Install the G++ compiler and Git
# Update package lists and install necessary packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    g++ \
    git

# Set the working directory inside the container
WORKDIR /usr/src/app
ARG CACHEBUST=1
# Copy the entire local monalisa directory into the container
COPY . /usr/src/app
# In the futureClone your GitHub repository
# RUN git clone https://github.com/MattechLab/monalisa.git

# Set the working directory to the folder containing your script
WORKDIR /usr/src/app/example/imDim_plus_card

# Set the default command to be executed when the container starts
CMD ["matlab", "-batch", "script"]
