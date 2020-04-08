---
layout: post
title:  "Getting started with the Google Coral EdgeTPU using C++"
date:   2020-04-06 21:00:00 +0200
categories: machinelearning
---

In the [last post](http://aul12.me/machinelearning/2019/12/10/inference-benchmark.html) i compared the inference 
speed of two neural networks using C++ on the CPU of a desktop computer. I stated, that for many applications
it is not possible to use accelerator devices such as GPUs. 
This changed in the last year with Google releasing an comparably cheap dedicated neural network accelerator:
the [Google Coral EdgeTPU module](https://coral.ai/products/).

In the simplest form the accelerator can be plugged into any available USB port on the computer 
(USB-3 is prefered but not necessary) and the inference can be run on the device. 
For a better integration there are also modules available which fit into a normal M.2 socket, 
which is usually used for SSDs. This modules communicates with the host computer via PCI-Express.

The integration of such an EdgeTPU is easy when considering the required hardware changes, especially when
comparing it to other accelerators such as GPUs. 
But the integration into the software which should use the TPU is not as easy.
The first constraint is that the model needs to be defined and trained using [TensorFlow](https://www.tensorflow.org/)
The models for the Coral need to be quantized, this means all floating point number need to be truncated to 8-bit
fixed point numbers. Additionally the model needs to be converted to a [TensorFlow Lite](https://www.tensorflow.org/lite)
model, and then compiled for the EdgeTpu.
When executing the model the TensorFlow Lite interpreter needs to be configured to use the Coral, this is especially
complicated when using the C++ interface which is not documented very well.

To simplify the application of the Google Coral Edgetpu i have compiled this blogpost to get started with the 
EdgeTpu using C++. For this post i assume that the reader is familiar with TensorFlow and is able to train a normal
model by him/herself.

## Installing all required components
To use the accelerator some software needs to be installed on the system, for most of the parts refer to the guide
on the linked website as the guide changes quite regularly.

Necessary components are:
 * [TensorFlow](https://www.tensorflow.org/install): for defining and training the model
 * [TensorFlow-Lite (Python)](https://www.tensorflow.org/lite/guide/python): for converting and quantizing the model
 * [Edge TPU Compiler](https://coral.ai/docs/edgetpu/compiler/): for compiling the model for the Edge TPU
 * [Driver for the EdgeTPU Device](https://coral.ai/docs/):
   * [USB-Accelerator](https://coral.ai/docs/accelerator/get-started)
   * [M.2 Accelerator](https://coral.ai/docs/m2/get-started)
   * [Dev-Board](https://coral.ai/docs/dev-board/get-started)
 * Tensorflow-Lite C++ interface (see below): for running the inference using C++

### Installing the TensorFlow-Lite C++ Interface
#### Preparations
First clone the official [TensorFlow-Repository](https://github.com/tensorflow/tensorflow) of GitHub:
```bash
git clone git@github.com:tensorflow/tensorflow.git
```
if you do not have a GitHub account or no SSH-Keypair the URL needs to be `https://github.com/tensorflow/tensorflow.git`.

You may want to check out an older version of TensorFlow (1.15) which is guaranteed to work, newer versions 
(starting with TensorFlow 2) are not guaranteed to work, in the directory of the repository (`cd tensorflow`), checkout
the tag `v1.15.0`:
```bash
git checkout v1.15.0
```

Next flatbuffers, a dependency of Tensorflow-Lite needs to be installed manually, for this clone the repository:
```bash
git clone git@github.com:google/flatbuffers.git
```
(or `https://github.com/google/flatbuffers.git`, like above).

Next build and install flatbuffers:
```bash
cd flatbuffers
mkdir build
cd build
cmake ..
make
sudo make install
```

#### Compiling TensorFlow-Lite
Change in the `tensorflow/lite/tools/make` directory (yes there is a `tensorflow` directory in the top level `tensorflow`
repository directory). First install all build dependencies by running, the `download_dependencies.sh` script:
```bash
chmod +x download_dependencies.sh
./download_dependencies.sh
```

Next you can compile the library, for this there is a script as well:
```bash
chmod +x build_lib.sh
./build_lib.sh
```
This will generate the file (relative to the `make` directory) `gen/linux_x86_64/lib/libtensorflow-lite.a` which is
the compiled library.

#### Installing/using TensorFlow-Lite
The easiest way to use the library is to install it systemwide, for this copy the library and the headers in the right
directoy, in the root directory of the repository run:
```bash
sudo cp tensorflow/lite/tools/make/gen/linux_x86_64/lib/libtensorflow-lite.a /usr/local/lib/
sudo cp -r tensorflow /usr/local/include/
```
as you can see this has the disadvantage that a large part of the repository needs to be copied to `/usr/local/include`.

If you do not want to do this (or do not have superuser permissions on the system), it is also possible to use the 
library without installation, this can be done by specifying the correct include directory and the path to the library
to your compiler (for example `gcc`):
```bash
gcc -I PATH_TO_TF/tensorflow -l PATH_TO_TF/tensorflow/lite/tools/make/gen/linux_x86_64/lib/libtensorflow-lite.a other flags
```

## Converting the model

## Running the inference
### Python

### C++
