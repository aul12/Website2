---
layout: page
title: Portfolio 
permalink: /portfolio/
---
# Portfolio
## Carolo Cup
I participated for five years at the [Carolo-Cup](https://wiki.ifr.ing.tu-bs.de/carolocup/en/carolo-cup) with Team "Spatzenhirn".
We scored third place in 2018, second place in 2021 and 2022 and won the Cup in 2019.

For the perception stack, I developed the road-marking detection, sign detection and obstacle detection using OpenCV and TensorFlow. In addition, I developed a new trajectory planner, based on ILQR, and implemented a new state estimation and 
localization for the vehicle using an unscented Kalman filter, all implemented in modern C++.
I was also responsible for the software project management and quality control using a sophisticated workflow using
GitLab.

![Carolo-Cup](../assets/img/carolo.jpg "Carolo-Cup"){:class="img-responsive" width="100%"}

## RoboCup Junior
From 2011 to 2016 I participated in [RoboCup Junior](https://junior.robocup.org/about/) (Soccer-Open League), with Team "Bodenseehaie" as the software team lead.
In 2015 we won the German championship and participated at the world championship in Hefei, China where we got third. 
In 2016 we won the overall world championship with our self-developed robots.

All software developed by our team is released as free software: 
[the main robot code](https://github.com/aul12/RobotDebug) which is written in C++ for the AtXmega microcontroller, 
[an algorithm for detecting the orange ball](https://github.com/aul12/ROBOT) using OpenCV with C++ and 
[a desktop program for debugging](https://github.com/aul12/RobotDebug) using Qt. 
More information can be found in [this blog post](http://aul12.me/robocup/2019/09/13/robocup-foss.html).
To extend our testing capabilities I developed a complete end-to-end simulator using Electron and Web-GL. 
This allowed us to test software independent of the hardware. 
The complete simulator is available on [Github](https://github.com/aul12/RoboCup-Simulation), licensed under GPLv3.

![RoboCup](../assets/img/robocup.jpg "RoboCup"){:class="img-responsive" width="100%"}

## Toolbox Plane
See [the corresponding page](/tbplane).

![Toolbox Plane](../assets/img/tbplane_programming.jpg "Toolbox Plane"){:class="img-responsive" width="100%"}

## Bike Simulation
Multiple python applications based around a common bicycle physics simulation framework.
The applications consist of a tool for calculating the optimal pacing strategy, a tool for estimating
the coefficient of drag (CdA) from a recorded activity, a tool for estimating the power given the time for
a segment and a tool for estimating the time for a segment given a power profile.

The framework and the bundled application are open source and available on [GitHub](https://github.com/aul12/BikeSimulation),
they are written in python using sympy and matplotlib as libraries.
For the optimal pacing strategy algorithms from the domain of optimal control have been employed.
The underlying physics of the simulation is documented extensively in the README file.

![Toolbox Plane](../assets/img/bike_simulation.png "Toolbox Plane"){:class="img-responsive" width="100%"}

## Sym++
For many algorithms it is necessary to calculate the derivatives of expressions, naive implementations often rely on finite differences,
which is neither precise nor fast, or require the user to specify the derivatives by hand which is error-prone and cumbersome.
To overcome this issue i implemented a library for symbolic computations using modern C++20, the library does all computations
during compile-time, there is no runtime overhead when compared to specifying the derivatives by hand. In addition the library allows
for the easy definition of symbolic expressions using normal C++ syntax, this even allows the reuse of functions for both symbolic and
normal computations.

The complete library, including extensive documentation, is available on [GitHub](https://github.com/aul12/Sym), licensed
under GPLv3.

```c++
// Initialize two variables which can be used to form expressions,
// at this point they have neither a type nor a value
sym::Variable<'a'> a;
sym::Variable<'b'> b;

// Build an expression from the variables
auto f = a*a + b - a * b;

// with .resolve the actual value can be calculated when all values are given
std::cout << f.resolve(a=1, b=2) << std::endl;

// Gradients/Derivatives can be calculated symbolically during compile time:
auto da_f = sym::gradient(f, a);
auto db_f = sym::gradient(f, b);

// Printing of functions is supported:
std::cout << sym::toString(da_f) << std::endl;

// The derivative is once again an expression which can be evaluated
std::cout << db_f.resolve(a=3, b=2) << std::endl;

// or the derivative can be calculated once more:
auto dadb_f = gradient(db_f, a);
```


## SerialToolbox
During the initial phase of software development for a microcontroller, I often feel the need to view data that the microcontroller sends via UART to a computer. 
This is why I developed SerialToolbox, to not only be able to send and receive data but also to do this using a multitude of different representations.
SerialToolbox is inspired by the program HTerm (which was sadly discontinued in 2008). It is written in modern C++17 using QT, the software is completely open source (licensed under GPLv3) and available on [GitHub](https://github.com/aul12/SerialToolbox).

![SerialToolbox](../assets/img/SerialToolbox.png "SerialToolbox"){:class="img-responsive" width="100%"}

## eduJS
A simple HTML-WYSIWYG-Editor with a JS editor for creating simple web apps using HTML5 and Javascript. I developed this program as a project for my former school, they were interested in quickly building apps in class to read sensor data. 
The code is available on [GitHub](https://github.com/aul12/eduJS) (Licensed under GPLv3), i also gave a talk on this application (in german), the slides are available on [Google
Drive](https://docs.google.com/presentation/d/16bmZYIa_k7B3Fv3K5naTQL9vzd_MBaoVq_4Ty2uxOfY/edit?usp=sharing).
