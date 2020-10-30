FROM tensorflow/tensorflow:latest-gpu-py3 AS rdkit-env


# Install runtime dependencies
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN add-apt-repository ppa:bkryza/onedata-1909-bionic


RUN apt-get update \
 && apt-get install -yq --no-install-recommends \
    ca-certificates \
    build-essential \
    git \
    cmake \
    wget \
    vim \
    libboost-dev \
    libboost-iostreams-dev \
    libboost-python-dev \
    libboost-regex-dev \
    libboost-serialization-dev \
    libboost-system-dev \
    libboost-thread-dev \
    libcairo2-dev \
    libeigen3-dev \
    python3-dev \
    python3-numpy \
    python3-cairo \
    libboost-atomic1.62.0 \
    libboost-chrono1.62.0 \
    libboost-date-time1.62.0 \
    libboost-iostreams1.62.0 \
    libboost-python1.62.0 \
    libboost-regex1.62.0 \
    libboost-serialization1.62.0 \
    libboost-system1.62.0 \
    libboost-thread1.62.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ARG RDKIT_VERSION=Release_2020_03_2
RUN wget --quiet https://github.com/rdkit/rdkit/archive/${RDKIT_VERSION}.tar.gz \
 && tar -xzf ${RDKIT_VERSION}.tar.gz \
 && mv rdkit-${RDKIT_VERSION} rdkit \
 && rm ${RDKIT_VERSION}.tar.gz

RUN mkdir /rdkit/build
WORKDIR /rdkit/build

RUN cmake -Wno-dev \
    -D CMAKE_BUILD_TYPE=Release \
    -D CMAKE_INSTALL_PREFIX=/usr \
    -D Boost_NO_BOOST_CMAKE=ON \
    -D PYTHON_EXECUTABLE=/usr/bin/python3 \
    -D RDK_BUILD_AVALON_SUPPORT=ON \
    -D RDK_BUILD_CAIRO_SUPPORT=ON \
    -D RDK_BUILD_CPP_TESTS=OFF \
    -D RDK_BUILD_INCHI_SUPPORT=ON \
    -D RDK_BUILD_FREESASA_SUPPORT=ON \
    -D RDK_INSTALL_INTREE=OFF \
    -D RDK_INSTALL_STATIC_LIBS=OFF \
    #-D PYTHON_EXECUTABLE=/usr/bin/python3 \
    #-D PYTHON_INCLUDE_DIR=/usr/include/python3.7 \
    #-D PYTHON_NUMPY_INCLUDE_PATH=/usr/lib/python3/dist-packages/numpy/core/include \
    ..

RUN make -j $(nproc) \
 && make install


RUN pip install jupyterlab
RUN pip install nltk
RUN pip install pandas
RUN pip install matplotlib
RUN pip install scikit-learn
RUN pip install Keras
RUN pip install tensorflow
RUN pip install tables
RUN pip install seaborn
RUN pip install selfies


WORKDIR /root
CMD jupyter lab --port=8888 --no-browser --ip=0.0.0.0 --allow-root


