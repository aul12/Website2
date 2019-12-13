---
layout: post
title:  "Comparing the inference speed of different tensorflow implementations"
date:   2019-12-10 20:00:00 +0200
categories: machinelearning
---
Machine learning started of as the research to emulate the human brain [1], in recent years the models developed moved further away from the structure of the human brain [2]. 
On the other hand state of the art models are now able to perform certain tasks better than humans [3], these rapid improvements in the last five to ten years lead to the utilisation of deep neural networks outside of the research domain [4]. 
Today most of the large tech companies, such as Google and Facebook, are using neural networks as part of their products.

Not only datacentre based applications, such as the ones of Google and Facebook, but also applications running on the edge of the networks, for example on smartphones, require a fast and efficient calculation of the neural networks to save energy and guarantee a quick response.
Especially devices on the edge of the internet are limited in computation power and often do not provide accelerator devices such as GPUs or dedicated neural network accelerators.
Thus it is of great importance to have frameworks and libraries which enable a quick inference of neural networks on a normal CPU.

In this post i will compare the inference of two neural networks with different implementations, namely the [OpenCV DNN-Module (OpenCV Version 3.4.8)](https://docs.opencv.org/3.4.8/d2/d58/tutorial_table_of_content_dnn.html), [CppFlow](https://github.com/aul12/cppflow) which is a wrapper around the TensorFlow C-API, and [TensorFlow-Lite](https://www.tensorflow.org/lite) which is flavour of the TensorFlow framework specialized on inference at the edge.

## Setup
In the following section the setup which was used to measure the performance is explained.

### The Neural Networks
For the evaluation two different Convolutional Neural Networks (CNNs) have been used. Both networks have been trained from scratch using TensorFlow (1.15), using the Keras API for the Semantic Segmentation and the NN-API for the classification. 

#### Semantic Segmentation
The first CNN is a fully convolutional neural network used for semantic segmentation, semantic segmentation is the process of assigning every pixel in the input image a unique class. 
In this case the input image is a greyscale image of size 128x128 aquired from the camera of an autonomous vehicle.
The CNN is used to determine for every pixel if it part of the road, which lane it is part of and if there are special features such as pedestrians isles.

The network consists of three pairs of convolutional layers followed by a max-pooling layer each. This reduces the input image by a factor of $$2 \times 2$$ each and enlarges the receptive field of the CNN. Upsampling is done with three transposed convolutional layers. 

![Semantic Segmentation Net](../../../../../assets/img/inference-benchmark/semseg.svg){:class="img-responsive" width="100%"}
*Structure of the Semantic Segmentation CNN, image created using NN-SVG [5]*

#### Classification
The second CNN is used for the classification of traffic signs, the input of the network is a color image of size 80x80.

The CNN consists of four convolutional layers followed by a max-pooling layer each, after the convolutional layer there are two fully connected layers, the first layer consists of 2048 neurons, the second layer of the 29 neurons that represent the probability density function for the classification.

![Classification Net](../../../../../assets/img/inference-benchmark/class.svg){:class="img-responsive" width="100%"}
*Structure of the Classification CNN, image created using NN-SVG [5]*

### Hardware used
The benchmark was run on a laptop with a Intel Core i5-3230M CPU, running Ubuntu 18.04.3 with Kernel Version 5.0.0-37. The laptop does not provide a dedicated graphics card.

### Test script
All measurements have been done using a [small C++ Script](https://github.com/aul12/TensorflowInferenceBenchmark), the scripts first loads the model (saved either as a protobuf file for CppFlow and OpenCV, or as a tflite file for TensorFlow-Lite), then runs the model ten times (TensorFlow allocates the memory on the first run, so the first run is a lot slower) and then runs the model 1000 times, each time with random input data.
The random input data simulates real data and thus makes sure that no caching or other optimizations are influencing the inference.
Over the 1000 runs the runtime of the inference is measures, from this data the average (mean) runtime, the standarddeviation of the runtime, the minimal runtime and the maximal runtime is calculated.

The program is compiled with GCC-8 using maximal optimization (`-O3`) for this target (`-march=native -mtune=native`).
OpenCV is compiled from source to use all instructions available on the CPU, especially vector instructions (SIMD).
For Tensorflow-Lite there is an option to set the number of threads. 
To test the influence of this parameter the benchmark is done with one to eight threads.

## Results
### Semantic Segmentation

![Semantic Segmentation Times](../../../../../assets/img/inference-benchmark/semSegPlt.svg){:class="img-responsive" width="70%"}

| Implementation | Mean (ms) | Standarddeviation (ms) | Min (ms) | Max (ms) |
| --- | --- | --- | --- | --- |
| OpenCV | 12.6762 | 3.24769 | 11.3089 | 34.6139 |
| CppFlow | 13.4546 | 0.526951 | 12.5265 | 21.6826 |
| TfLite (1 Thread) | 21.2997 | 0.285547 | 21.0454 | 24.4562 |
| TfLite (2 Threads) | 21.0152 | 1.78953 | 16.5106 | 31.8352 |
| TfLite (3 Threads) | 20.3686 | 1.2116 | 16.3625 | 25.7325 |
| TfLite (4 Threads) | 18.0461 | 1.55253 | 15.7319 | 22.4034 |
| TfLite (5 Threads) | 17.5016 | 1.53257 | 15.6677 | 27.479 |
| TfLite (6 Threads) | 17.7587 | 1.637 | 15.6416 | 26.0748 |
| TfLite (7 Threads) | 17.6306 | 1.51185 | 15.6903 | 25.3047 |
| TfLite (8 Threads) | 17.7098 | 1.49929 | 15.7096 | 22.5983 |

### Classification

![Classification Times](../../../../../assets/img/inference-benchmark/classPlt.svg){:class="img-responsive" width="70%"}

| Implementation | Mean (ms) | Standarddeviation (ms) | Min (ms) | Max (ms) |
| --- | --- | --- | --- | --- |
| OpenCV | 5.54286 | 0.827205 | 4.44979 | 12.9081 |
| CppFlow | 6.14033 | 0.485032 | 5.43162 | 13.4802 |
| TfLite (1 Thread) | 186.294 | 21.5911 | 179.202 | 395.874 |
| TfLite (2 Threads) | 97.7576 | 5.2064 | 96.3869 | 181.526 |
| TfLite (3 Threads) | 96.0766 | 3.03276 | 94.7009 | 138.22 |
| TfLite (4 Threads) | 92.1016 | 6.11409 | 90.7117 | 262.123 |
| TfLite (5 Threads) | 105.2 | 6.31152 | 98.5465 | 238.183 |
| TfLite (6 Threads) | 108.448 | 8.0407 | 99.8085 | 276.516 |
| TfLite (7 Threads) | 111.563 | 7.24448 | 100.883 | 167.064 |
| TfLite (8 Threads) | 115.194 | 8.70729 | 102.432 | 243.71 |


## Conclusion
For both networks OpenCV yields on average the lowest inference time, both times closely followed by CppFlow. 
The differences between those two frameworks can mainly be attributed to the optimized instructions (like SIMD), that OpenCV uses at it was compiled from source, but CppFlow does not use as the Tensorflow C-API was installed as a binary which needs to run on a wide variety of systems.

One advantage of CppFlow over OpenCV, is that CppFlow is guaranteed to support all operations that Tensorflow supports. For OpenCV there are some operations which are not supported, in this case the model can not be loaded.

The Tensorflow-Lite implementation is slower for both of the networks. For the Semantic Segmentation the difference is between a factor of 1.6 and 1.3, for the classification task the difference is much larger, the factor is between nearly 32 and 15. 
Especially for the second task the difference in inference speed is huge.
Additionally it can be noted for Tensorflow-Lite that the runtime is mostly not influenced by the number of cores.
Intuitively the runtime should be inverse proportional to the runtime as most of the operations can be easily parallelized (that is the reason for the speed and thus popularity of GPUs).

To verify the correctness of the Tensorflow-Lite installation the same measurements have been made on a different computer, using the r1.15 version of TensorFlow and TensorFlow-Lite (Commit `590d6ee`). 
The computer is equipped with a faster CPU, an Intel Core i7-6700, so a faster inference of the CNN was expected.
Considering the absolute runtime the inference took about half the time when compared to the same setup on my laptop.
This improvement is primarily due to the faster CPU, overall the inference on my laptop is still about ten times faster when using OpenCV or CppFlow, even though my laptop is slower.

When researching this behaviour of Tensorflow-Lite the only similar problems are bug reports on GitHub which are from 2017 and 2018 [6]. 
The cause of the discrepancy could not be found so as a result Tensorflow-Lite can, for now, not be recommended if it is possible to use an alternative such as OpenCV or CppFlow.

## References
 * [1] A. L. Hodgkin, A. F. Huxley: A Quantitative Description of Membrane Current and its Application to Conduction and Excitation in Nerve. In: The Journal of Physiology. Band 117, 1952, S. 500–544
 * [2] Laskar, Md Nasir Uddin, Luis Gonzalo Sánchez Giraldo and Odelia Schwartz. “Correspondence of Deep Neural Networks and the Brain for Visual Textures.” ArXiv abs/1806.02888 (2018): n. pag.
 * [3] IJCNN2011 Competition Results: [http://benchmark.ini.rub.de/?section=gtsrb&subsection=results](http://benchmark.ini.rub.de/?section=gtsrb&subsection=results)
 * [4] A. Luckow, M. Cook, N. Ashcraft, E. Weill, E. Djerekarov and B. Vorster, "Deep learning in the automotive industry: Applications and tools," 2016 IEEE International Conference on Big Data (Big Data), Washington, DC, 2016, pp. 3759-3768.
 * [5] NN-SVG: [https://alexlenail.me/NN-SVG/](https://alexlenail.me/NN-SVG/)
 * [6] GitHub: "tflite runs much slower than tfmobile ..." [https://github.com/tensorflow/tensorflow/issues/21787](https://github.com/tensorflow/tensorflow/issues/21787)

