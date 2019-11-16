# Detect Multi Label Image through Single Label Classifier

Detailed Thesis Paper can be found [here](https://github.com/shubhashis-k/multi-image-classifier-convnet/blob/master/Thesis.pdf)

The primary methodology is the following:

![methodology](https://github.com/shubhashis-k/multi-image-classifier-convnet/blob/master/Workflow.JPG)

So, from the methodology there are two phases. 
- Segment the images
- Feed the segmented images through the convolutional neural network


In the repo there are two folders,

**TrainerAndServer:**
- Contains codes for training and testing CIFAR-10 datasets
- The CIFAR-10 datasets are trained with Convolutional Neural Network
- Also contains server side codes for communicating with segmented images

**ImageDetectorApp:**
- Android application to provide a default interface to segment the image and show results.
