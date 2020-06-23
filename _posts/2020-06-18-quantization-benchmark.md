---
layout: post
title:  "Comparing the inference performance of neural networks with and without quantization"
date:   2020-06-18 16:00:00 +0200
categories: machinelearning
---

In my post 
["Getting started with the Google Coral EdgeTPU using C++"](https://aul12.me/machinelearning/2020/04/06/edgetpu-cpp.html)
i described that models for the Google Coral EdgeTPU module need to be quantized to 8-bit fixed point
numbers, instead of the commonly used 32 or 64-bit floating point numbers. This reduces the resolution of all values
used in the model, that are the weights, the intermediate results and the predictions. Therefore the quality of the
predictions of the neural networks is in most cases worse than without quantization.

In the blog post i will examine the differences in performance for a convolutional neural network using different
metrics.
This helps to not only understand the direct impact on the accuracy of the network but to further characterize
the differences in the outputs.
The TensorFlow team themselves examined the performance of quantization on four widely used convolutional neural networks but only 
reported the accuracy as metric (See: 
[TensorFlow - Model optimization](https://www.tensorflow.org/lite/performance/model_optimization)).

## Setup
The network used is the same classification network as listed in the post 
["Comparing the inference speed of different tensorflow implementations"](https://aul12.me/machinelearning/2019/12/10/inference-benchmark.html).
To summarize the structure: it consists of four convolutional layers each followed by a max-pooling operation and a
ReLU nonlinearity. After the convolutional layers there are two fully connected layers with a softmax prediction at the output.
The input is of size $$80\times 80 \times 3$$, the output consists of 30 classes. 
One of the classes (class 29) is the *NO_CLASS* class, this class consists of samples which do not show any of
the valid classes. See the appendix for the full list of classes and their semantic interpretation.

The models with and without quantization are exactly the same model, the quantized model was converted from
the normal model using post-training quantization. 
The complete dataset consists of 53299 images. Using this dataset two different models have been trained: for
the first model most of the samples have been used for training (to be precise 47969 of 53299), and all samples
have been used for evaluation. This is how the model is used for the actual deployment. For the second model
the dataset has been divided in a training set of size 38867 and a verification set of size 10114. The samples
in the subsets are completly different as they were recorded at different times. 
For training only the training set is used and for the evaluation only the verification set. 
This training procedure is different to the one used for deployment but this guarantees that the results are not 
influenced by overfitting. In the next sections the first setup is refered to as the full configuration and the
second as the verification configuration.

The complete code used for testing can be found on my GitHub page:
[github.com/aul12/NeuralNetworkQuantizationPerformanceBenchmark](https://github.com/aul12/NeuralNetworkQuantizationPerformanceBenchmark).

## Comparison
### Accuracy
The first metric is the accuracy of the classifier on the dataset, for this we calculate the prediction as the class
with the highest probability. A prediction is correct if it is the same as the label. The accuracy is then calculated
as the number of correct predictions divided by the total number of samples.

| Model | Accuracy (Full) | Accuracy (Verification) |
| --- | --- |
| Without Quantization | 99.85% | 99.83% |
| With Quantization | 96.93% | 58.14% |

The performance of the quantized model is about three percent points worse than the performance of the normal
model when comparing on the full configuration. 
This is a slightly better relative performance of the quantized model than the numbers reported by the TensorFlow team.
When comparing using the verification configuration the results are vastly different: the floating-point model yields a similar
result but the performance of the quantized model drops from 96.93% to 58.14%, a decrease by 38.79% percent points.

Additionally to the accuracy a confusion matrix for both models and configurations has been created, 
see the appendix for the full matrices and the semantic interpretation of the label numbers.
As already implied by the accuracy most of the entries of the confusion matrices are located on the primary diagonal.
Without quantization the incorrect classifications are distributed evenly throughout the confusion matrix for both
configurations.

For the non quantized model on the full dataset there are two main error sources:
 * The different speedlimit signs can not be differentiated as clearly as the non quantized model can
 * In comparison to the non quantized model more images of type *NO_CLASS* are classified as a relevant

The additional problems using the verification configuration are:
 * Left- and Rightarrows can not be differentiated as good as before
 * Sharp-Turn-Left and -Right can not be differentiated as good as before
 * No passing start/end is often classified as a speedlimit, probably due to the red circle on the signs


### Output probabilities
The softmax activation function used in the last layer yields a valid probability density function (pdf) over the classes.
This means that all values are in the range $$[0, 1]$$ and the sum over all 30 values is 1. The classification
result is determined as the class with the maximal probability. Additionally to this hard classification information
the result can also be used for additional filtering, especially in application in which the same object gets classified
multiple times.

To compare the quality of the pdfs the probalities are evaluated. A good pdf clearly shows the winner but additionally
provides certainty information, i.e. the output pdf is not a one-hot-distribution. For the comparison two different
sets of values are compared:
 * the certainty, that is the probability of a correct classification
 * all output values, that are both the certainty and the probabilities for all other classes

For this evaluation the full configuration is used if not specified differently. The differences between the configurations
are small.
Over both of these set of values for both models a histogram over the values is calculated. These histograms are given below,
additionally there are the raw values further below.

![Certainty Values with Quantization](../../../../../assets/img/quantization-benchmark/quant_cert.svg){:class="img-responsive" width="49%"}
![Certainty Values without Quantization](../../../../../assets/img/quantization-benchmark/float_cert.svg){:class="img-responsive" width="49%"}

![Output Values with Quantization](../../../../../assets/img/quantization-benchmark/quant_out.svg){:class="img-responsive" width="49%"}
![Output Values without Quantization](../../../../../assets/img/quantization-benchmark/float_out.svg){:class="img-responsive" width="49%"}

| Range | Certainty Quant. | Certainty float | Out Quant. | Out float |
| --- | --- | --- | --- | --- |
| $$[0, 0.05)$$ | $$0$$ | $$0$$ | $$0.96$$ | $$0.97$$ | 
| $$[0.05, 0.1)$$ | $$0$$ | $$0$$ | $$3.1 \cdot 10^{-5}$$ | $$0$$ |
| $$[0.1, 0.15)$$ | $$0$$ | $$0$$ | $$0.00060$$ | $$0$$ |
| $$[0.15, 0.2)$$ | $$0$$ | $$0$$ | $$0.00012$$ | $$0$$ |
| $$[0.2, 0.15)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.25, 0.3)$$ | $$3.9 \cdot 10^{-5}$$ | $$0$$ | $$9.5 \cdot 10^{-5}$$ | $$0$$ |
| $$[0.3, 0.15)$$ | $$0.00075$$ | $$0$$ | $$0.00027$$ | $$0$$ |
| $$[0.35, 0.4)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.4, 0.45)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.45, 0.5)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.5, 0.55)$$ | $$0.011$$ | $$0$$ | $$0.0016$$ | $$0$$ |
| $$[0.55, 0.6)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.6, 0.65)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.65, 0.7)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.7, 0.75)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.75, 0.8)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.8, 0.85)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.85, 0.9)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.9, 0.95)$$ | $$0$$ | $$0$$ | $$0$$ | $$0$$ |
| $$[0.95, 1]$$ | $$0.98$$ | $$1$$ | $$0.32$$ | $$0.033$$ |

The results are surprising: the non quantized model yields in general more one-hot-like results, when compared
to the quantized model which yields a more uniform distributions. When considering the absolute scale
it can also be seen that the actual differences are relativly small, both distributions look, especially when
only considering the histograms, very similar.

To further characterize the pdfs the [(Shannon) entropy](https://en.wikipedia.org/wiki/Entropy_(information_theory))
is calculated for every sample and the average entropy over all samples is calculated for both models. The entropy
can be used as measure for the uniformity of a distribution. A completly uniform distribution for a pdf of dimension
$$N$$ yields an entropy of $$\log_2(N)$$, for a one hot distribution the entropy is $$0$$. To make the score independent
of the dimension of the output space the entropy is normalized by a factor of $$\frac{1}{\log_2(N)}$$, so that the
score for a uniform distribution is $$1$$. 

The average entropy is given in the table below:

| Model | Average normalized Entropy (full) | Average normalized entropy (verification) |
| With Quantization | $$0.0089$$ | $$0.021$$ |
| Without Quantization | $$0$$ | $$0$$ |

These numbers imply the same result as the histogram: the output pdf for the non-quantized model is strictly one
hot, the quantized modell has a more uniform distribution. Still the differences are rather small.

## Results
The results are twofold: primarily the accuracy of the quantized classifier is reduced drastically when evaluating on 
a different dataset. Depending on the applications the results can be sufficient, especially considering that the errors
are predictable, but in general the loss in accuracy renders the quantized model unusable.

Secondly the output pdf is not one-hot encoded anymore but yields more soft-encoded
labels. For most applications the difference is neglectible, even the labels of the quantized
model are nearly one-hot-encoded.

## Appendix

### Confusion Matrices

 * [ConfusionMatrix (full configuration)](../../../../../assets/quant-confusion-matrix-full.html)
 * [ConfusionMatrix (verifcation configuration)](../../../../../assets/quant-confusion-matrix-verification.html)

### Labels
The classes are defined by the Carolo-Cup-Regulations, see the official rules for more information:
[wiki.ifr.ing.tu-bs.de/carolocup/system/files/Master-Cup%20Regulations.pdf](https://wiki.ifr.ing.tu-bs.de/carolocup/system/files/Master-Cup%20Regulations.pdf)

| Name | Label Number |
| --- | --- |
|CROSSWALK|         0|
|STOPLINE|          1|
|GIVE_WAY_LINE|     2|
|R_ARROW|           3|
|L_ARROW|           4|
|FORBIDDEN|         5|
|SPEEDLIMIT10|      6|
|SPEEDLIMIT20|      7|
|SPEEDLIMIT30|      8|
|SPEEDLIMIT40|      9|
|SPEEDLIMIT50|      10|
|SPEEDLIMIT60|      11|
|SPEEDLIMIT70|      12|
|SPEEDLIMIT80|      13|
|SPEEDLIMIT90|      14|
|NSPEEDLIMIT|       15|
|STARTLINE_PARKING| 16|
|CROSSINGLINE|      17|
|PEDESTRIAN|        18|
|EXPRESS_START|     19|
|EXPRESS_END|       20|
|NO_PASSING_START|  21|
|NO_PASSING_END|    22|
|UPHILL|            23|
|DOWNHILL|          24|
|PEDESTRIAN_ISLAND| 25|
|SHARP_TURN_RIGHT|  26|
|SHARP_TURN_LEFT|   27|
|RIGHT_OF_WAY|      28|
|NO_CLASS|          29|

