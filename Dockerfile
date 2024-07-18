# Use the official Python base image
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Install necessary dependencies and update CA certificates
RUN apt-get update && \
    apt-get install -y git curl ca-certificates && \
    apt-get clean && \
    update-ca-certificates

COPY certs/*.crt /usr/local/share/ca-certificates/

# Upgrade pip and install PyTorch without SSL verification
RUN pip install --upgrade pip --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host download.pytorch.org --no-cache-dir --disable-pip-version-check --timeout=60 --retries=3
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org --trusted-host download.pytorch.org torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu --disable-pip-version-check --no-cache-dir --timeout=60 --retries=3

# Install einops
RUN pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org einops

# Copy the contents of the current directory (matmulfreellm repository) into /app/matmulfreellm in the container
COPY . /app/matmulfreellm

# Change working directory to matmulfreellm
WORKDIR /app/matmulfreellm

# Install matmulfreellm dependencies
RUN if [ -f requirements.txt ]; then pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org -r requirements.txt; fi

# Clone the triton repository
RUN git clone https://github.com/openai/triton.git /app/triton

# Change working directory to triton
WORKDIR /app/triton

# Create setup.py file for triton
COPY triton_files/setup.py /app/triton/setup.py

# Create src directory and move the relevant package directories into it
RUN mkdir src
RUN cp -r /app/triton/lib /app/triton/src/lib
RUN cp -r /app/triton/cmake /app/triton/src/cmake
RUN cp -r /app/triton/include /app/triton/src/include
RUN cp -r /app/triton/unittest /app/triton/src/unittest
RUN cp -r /app/triton/third_party /app/triton/src/third_party
RUN mkdir -p src/triton

RUN mv /app/triton/python/triton/* /app/triton/src/triton/
RUN rm /app/triton/src/triton/_C/include
RUN ln -s /app/triton/include /app/triton/src/triton/_C/include

RUN apt-get update && apt-get install -y ca-certificates
#
## Install the triton package with trusted hosts
#RUN apt-get update
#RUN apt-get install -y cmake
#RUN apt-get install -y libomp-dev
#RUN pip install --upgrade setuptools --trusted-host pypi.org --trusted-host files.pythonhosted.org
#RUN MAX_JOBS=16 python setup.py build_ext --inplace
#RUN MAX_JOBS=16 pip install --trusted-host pypi.org --trusted-host files.pythonhosted.org .
#
#
## Verify and fix triton location
#RUN triton_location=$(pip show triton | grep Location | awk '{print $2}') && mkdir -p "$triton_location/triton" && cp -r /app/triton/src/triton/_C "$triton_location/triton/_C"
#
## Change back to the matmulfreellm directory
#WORKDIR /app/matmulfreellm
#
## Define the default command
#CMD ["python3"]
