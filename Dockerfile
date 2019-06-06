FROM centos:7

LABEL maintainer "Koichi Kunii <kuniiskywalker@gmail.com>"

RUN yum -y update && yum -y install which wget unzip gcc patch gcc-c++
# Upgrade git for version 2.x
RUN yum -y remove git
RUN yum -y install https://centos7.iuscommunity.org/ius-release.rpm
RUN yum -y install git2u yum-utils

# Install Python3.x
RUN yum install -y python36u python36u-libs python36u-devel python36u-pip
RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3.6 /usr/bin/python
RUN ln -s /usr/bin/pip3.6 /usr/bin/pip
RUN sed -i -e "s/python/python2.7/" /usr/bin/yum

# Yum clean
RUN rm -rf /var/cache/yum/* \
  && yum clean all

# Install bazel
WORKDIR "/usr/local/src"
RUN wget https://github.com/bazelbuild/bazel/releases/download/0.24.1/bazel-0.24.1-installer-linux-x86_64.sh
RUN chmod 755 bazel-0.24.1-installer-linux-x86_64.sh
RUN ./bazel-0.24.1-installer-linux-x86_64.sh
RUN rm ./bazel-0.24.1-installer-linux-x86_64.sh

# Build tensorflow install package
RUN git clone https://github.com/tensorflow/tensorflow && cd tensorflow && git checkout -b v1.13.1
WORKDIR "/usr/local/src/tensorflow"
RUN pip install numpy keras_preprocessing
RUN ./configure
RUN bazel build -c opt //tensorflow/tools/pip_package:build_pip_package

# Install tensorflow from source
RUN pip install wheel
RUN bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/tensorflow_pkg --project_name tensorflow_gpu_cuda_10.0
RUN pip install /tmp/tensorflow_pkg/tensorflow_gpu_cuda_10.0-1.13.1-cp36-cp36m-linux_x86_64.whl
RUN rm -Rf /usr/local/src/tensorflow

# Change directory (cd) to any directory on your system other than the tensorflow subdirectory
WORKDIR "/app"
