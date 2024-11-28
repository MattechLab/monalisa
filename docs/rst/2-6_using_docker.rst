============================
Running Monalisa with Docker
============================

This guide will walk you through the steps to run Monalisa using Docker, enabling you to leverage our library on clusters.

Dockerfile Setup
================

We provide a `Dockerfile` that correctly sets up the container for running our functions. This Dockerfile is a modified version based on the official guidelines provided by MathWorks for generating Dockerfiles for MATLAB. 

- Reference: `MathWorks MATLAB Dockerfile <https://github.com/mathworks-ref-arch/matlab-dockerfile/blob/main/Dockerfile>`_

License Requirements
====================

To use MATLAB remotely via Docker, you must either have access to a license server or possess a license file. Detailed instructions for setting this up can be found here:

- Reference: `MATLAB Dockerfile Licensing Information <https://github.com/mathworks-ref-arch/matlab-dockerfile?tab=readme-ov-file#use-the-network-license-manager>`_

Steps to Run Monalisa
=====================

1. **Clone the Repository:**

   First, clone the repository containing the necessary files:

   .. code-block:: bash

      git clone https://github.com/YourRepository/monalisa.git

2. **Create or Use a Script:**

   Create the script you want to run with MATLAB inside the Docker container. As an example, you can use the provided script:

   - Test Script: `testDocker.m <https://github.com/MattechLab/monalisa/tree/main/examples/scripts/testDocker.m>`_

3. **Build the Docker Image:**

   Build the Docker image using the following command. Make sure to replace `LICENSE_SERVER` with your actual license server information:

   .. code-block:: bash

      sudo docker build --build-arg LICENSE_SERVER=port@servername -t my_matlab_image_name .

4. **Run the Docker Image:**

   Run the Docker image with the following command, replacing `localpathto/recon_eva` with your local directory path:

   .. code-block:: bash

      sudo docker run --init --rm -v localpathto/recon_eva:/usr/src/app/recon_eva my_matlab_image_name

Congratulations! You are now running Monalisa in a Docker container.

**Note:** 
You will likely build the Docker image locally, push it to Docker Hub, and then pull it on your remote cluster where you will run it. If you are unfamiliar with basic Docker operations, this guide assumes you already have that knowledge, so consider starting with Docker basics if needed.
