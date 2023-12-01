
ARG MATLAB_RELEASE=r2023b

# Specify the extra toolboxes to install into the image.
ARG ADDITIONAL_PRODUCTS="Automated_Driving_Toolbox Model_Predictive_Control_Toolbox Optimization_Toolbox Simulink Simulink_Test Simulink_Coverage Simulink_Design_Verifier Requirements_Toolbox"
FROM mathworks/matlab:$MATLAB_RELEASE
USER root

# Declare the global argument to use at the current build stage
ARG MATLAB_RELEASE
ARG ADDITIONAL_PRODUCTS

# Install mpm dependencies
RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update \
    && apt-get install --no-install-recommends --yes \
    wget \
    unzip \
    ca-certificates \
    && apt-get clean \
    && apt-get autoremove \
    && rm -rf /var/lib/apt/lists/*

# Run mpm to install MathWorks products and toolboxes into the existing MATLAB installation directory,
# and delete the mpm installation afterwards.
# If mpm fails to install successfully then output the logfile to the terminal, otherwise cleanup.
WORKDIR /tmp
RUN wget -q https://www.mathworks.com/mpm/glnxa64/mpm \
    && chmod +x mpm \
    && EXISTING_MATLAB_LOCATION=$(dirname $(dirname $(readlink -f $(which matlab)))) \
    && ./mpm install \
        --destination=${EXISTING_MATLAB_LOCATION} \
        --release=${MATLAB_RELEASE} \
        --products ${ADDITIONAL_PRODUCTS} \
    || (echo "MPM Installation Failure. See below for more information:" && cat /tmp/mathworks_root.log && false) \
    && rm -f mpm /tmp/mathworks_root.log


# Now that the installation is complete, switch back to user "matlab"
USER matlab
WORKDIR /home/matlab
# Inherit ENTRYPOINT and CMD from base image.
