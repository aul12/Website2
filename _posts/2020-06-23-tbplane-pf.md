---
layout: post
title:  "Toolbox-Plane Update - Part 1: State Estimate"
date: 2020-06-23 20:30:00  +0200
categories: tbplane
---

As a result of the Corona pandemic i had a lot of time available during the period between the winter and the summer
semesters. Some of this time was spent by implementing new features for our [Toolbox-Plane](http://aul12.me/tbplane/)
flight computer. The flight computer is a Rasperry Pi which runs all high-level aspects of the plane such as
sensor fusion, route planning and some parts of the feedback-control. Additionally it is the centre of our
communication network: the flight computer communications with the flight controller, the power distribution board, 
the primary remote and the base station.

This is part 1 of a series of posts, this post will explain our updated state estimation using a particle filter.

## State Estimation using a Particle Filter
The plane is equipped with a lot of sensors, the important sensors are:
 * an IMU
 * a altimeter (air pressure based)
 * a GPS receiver
 * a ultrasonic distance sensor for landing
 * a pitot-tube for (relative) air speed

The sensors all provide some form of position or rotations measurement or a derivative thereof. 
This position and rotation is what is refered to as the state of the plane. The job of a state estimator
is to infer this state from the, in general noisy, measurements. 
There are more measurements than there are state variables, thus there is (in general) direct inverse measurement model 
for calculating a state from a given set of measurements.
Additionally such an approach would only consider the measurements at a single time step, as the sensors can
produce outliers it would be preferable to detect these outliers using our knowledge about the dynamic of the airplane.

So in short we want a filter which considers the certainties of our measurement, the last measurements and the possible
movement of the plane (i.e. the system dynamics) to predict the current state. 

### Basics
Such a task is typically solved using a bayesian filter, given a set of measurements $$Z = \{z_1, \ldots, z_t\}$$ we
want the best estimate $$\hat{x}_t$$ for our state $$x_t$$ at timestep $$t$$:

$$ \hat{x}_t = \text{argmax}_t P(x | Z) = \text{argmax}_x \frac{P(Z|x) \cdot P(x)}{P(Z)} = \text{argmax}_x P(Z|x) \cdot P(x)$$

The main idea here is, that our measurements and states are not numbers but random variables, thus we have nicely
solved the problem that our model is not directly invertible and additionally added the option to model sensor noise.
This idea of a-priori-probability maximization for random variables (often called a MAP-estimator) is the central idea
for all bayesian filters.

As this optimization problem is quite complex and not solveable for most cases we simplify it using the assumption
of a first order markov model: that is a measuremnt is only influenced by the current state and not by states at other
time steps. Or in other words: we have described the complete system dynamics using our model, there are no hidden
dynamics which we did not describe.
This enables us to simplify the probability:

$$ P(x | z_1, \ldots , z_n) \equiv P(Z|x) \cdot P(x) = P(z_n | x) \int_{x_{t-1}} \cdot P(x | x_{t-1}) \cdot P(x_{t-1} | z_{t-1}) \text{d}x_{t-1} $$

So our resulting probability is given as the product of our measurement likelihood and the transistion probability
over all possible previous states.

To make this more applicable we define our system- and our measurement-model as two (time discrete) functions:

$$ x_{t+1} = f(x_{t})$$

$$ y_{t} = h(x_{t}) $$

With this nomenclature $$x$$ is the state, $$y$$ the measurement, $$f: \mathbb{R}^n \to \mathbb{R}^n$$ our system model
and $$h: \mathbb{R}^n \to \mathbb{R}^m$$ our measurement model. Later on we will use these definitions for the particle
filter, note that $$f$$ influences the transition probability $$P(x_t|x_{t-1})$$ and $$h$$ influences the measurement
probabilty. But as there is, in most cases, no explicit formulation of this relation we need to rely on approximations.

### Particle Filter
For some cases there is a closed form solution for this optimization problem, namely for random variables which
follow a gaussian distribution with linear system and measurement models. This is the famous Kalman filter. For other
cases, primarily with gaussian distributions and nonlinear systems there are good approximations such as the
extended- and unscented Kalman filter. In our case we can not consider gaussian distributions, as many sensors have
a non neglectable resolution and other sensors such as the ultrasonic sensor yield non gaussian noise if the plane
is over a certain altitude. Furthermore our plane is obviously highly nonlinear.

Thus we can not rely on a Kalman filter or any of its derivatives. Instead we rely on a numerical approximation
using Monte-Carlo sampling: the particle filter. The particle filter relies on the theory provided above but uses
an approximation of the probability density functions in the form of samples which are drawn from the distribution.
These samples are called a particle set and represent state hypotheses. The algorithm is recursively calculated and
consists of the following steps:
 * All particles are predicted from the last time to the current time step using $$f$$
 * For every particle a measurement hypothesis is calculated using $$h$$
 * All measurement hypothesis are weighted using the probability density function provided by the actual measurement
 * A single state estimate is generated from the particles, often using the weighted average (i.e. the expectation)
 * A resampling step can be added: unprobable particles are removed from the set and more probable particles are created

Particles filters are often applied for localization tasks but also for more advanced multi object tracking schemes.
The following tweet has quite a nice animation describing the particle filter for localization. As the state space
is two dimensional the particles, which are location hypothesis, can be plotted nicely:

<center>
<blockquote class="twitter-tweet"><p lang="en" dir="ltr">Particle filters are general algorithms for inferring the state of a system with noisy dynamics and noisy measurements. Here&#39;s an example with a robot in a circular room. Red=true robot, blue=guesses, occasional red line=noisy range sensor measurement. Details in thread 1/ <a href="https://t.co/1UnJjnJYPT">pic.twitter.com/1UnJjnJYPT</a></p>&mdash; Andrew M. Webb (@AndrewM_Webb) <a href="https://twitter.com/AndrewM_Webb/status/1184559073913704448?ref_src=twsrc%5Etfw">October 16, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
</center>

More information on the topic can be found in the books
"Estimation with Applications to Tracking and Navigation: Theory, Algorithms and Software" by Bar-Shalom, Li and
Kirubarajan and "Probabilistic Robotics" by Thrun, Burgard and Fox.

### Application in the Flightcomputer
For our plane the sensor readings are:
 * Roll angle
 * Angular roll rate
 * Pitch angle
 * Angular pitch rate
 * Yaw angle
 * Angular yaw rate
 * Relative air speed
 * Ground speed
 * Vertical speed 
 * Altitude as measured by the altimeter
 * Altitude as measured by the GPS
 * Distance over ground 
 * Latitude
 * Longitude

The state consists of:
 * Roll angle
 * Angular roll rate
 * Pitch angle
 * Angular pitch rate
 * Yaw angle
 * Angular yaw rate
 * Absolute speed
 * Altitude
 * Altitude above ground
 * Latitude
 * Longitude

Most of the measurement variables are directly equal to the state variables. The other variables consider the orientation
of the plane and are thus related via trigonometric functions. Thus we can see that the measurement model is nonlinear.
For the process model we assume a one-dimensional constant velocity model with consideration of the orientation
to calculate the velocity and position. For the rotational axis we use a constant turn rate model on all three axis.
See 
[Filters/Fusion/Lib/system.c](https://github.com/ToolboxPlane/FlightComputer/blob/master/Filters/Fusion/Lib/system.c)
for the full definition of the system and the measurement model used. Additional to the set of scalar measurement
values we have a set of additional measurement information, this includes the certainties provided by the GPS and an estimate
of the certainty of the barometer based on the distance and time difference from the calibration.

We are currently running the filter single threaded, as other parts of the
software are suffiently parallelized to use the complete CPU. With a sensor update rate of approximatly 100ms
we can use 300000 particles for the state estimation, this is most definetly overkill, the results are already quite
good even with 1000 particles.

### Implementation Details

#### Floating Point Errors
The position of the plane is described by the latitude and longitude, so an absolute global position is used to allow
the plane to fly everywhere.
Especially when the plane is moving slowly, for example during launch, the difference in position between two timesteps
is rather small. When describing this distance using global coordinates the differences between the coordinates is very
small. Additionally the number become even smaller when they are multiplied with the weight of the particle and then
summed up. This results in state estimates which can differ as much as ten meters from the actual prediction (if there
where no floating point errors). This does not get better even when using wider types, such as the (non standardized)
128-bit `long double` types provided by GCC.

The problem is a result of the representation of floating point numbers in modern CPUs. This representation is defined
by IEEE-754: to keep it short a number is represented by the sign, the mantissa which is a factor in $$[1, 2]$$ and
an exponent, so that the number is calculated as

$$\text{number} = \text{sign} \cdot \text{mantissa} \cdot 2^\text{exponent}$$

thus the fractional resolution of a number depends on the absolute scale of the number. I.e. the lower a number
the higher the fractional resolution of the number. Applying this onto our problem we see that we can achieve a
higher resolution for our coordinates if we transform then into the origin of our coordinate system.
For this transformation we use the first particle as offset, using this offset we first subtract the offset from all
particles, then calculate the weighted sum and at the end add the offset. In combination with using the [Kahan summation
algorithm](https://en.wikipedia.org/wiki/Kahan_summation_algorithm) stable predictions are achieve.

#### Different Sensor Update Frequencies
For the particle filter multiple sensors are used as input, these sensors provide measurements at different
frequencies. This is something that is not directly possible when using a particle filter, as the algorithm is based
on the recursive prediction and update step. 

The main idea is to run the particle filter at a fixed frequency and add the different measurements once they are
available. If there is no data available from a sensor this measurement is not used for weighting the particle.
This allows to only use a subset of the sensors at each timestep. This also helps if sensor measurements are missing
or connections to sensors get lost. For example if the GPS fix is lost the particle filter automatically switches
to a pure prediction based scheme, using the other sensors for dead reckoning.

#### Sensor Resolution
Another improvement that can be implemented by using a particle filter, when compared to Kalman filter derivative, is
the option to model limited sensor resolution. This is expecially important for the barometer which has a resolution
of one meter. During landing it is important to have a altitude estimate with a resolution which is lower than one meter
so it is not possible to ignore this sensor resolution when modeling the system. The solution is actually quite easy:
the measurement model is expanded to simply contain this quantization step as well. So if the altitude of a particle
is $$x.49$$ meters, and that of another particle is $$x.0$$ both are transformed to $$x.0$$ in the measurement step,
thus the particles are equiprobable. As the sensors itself would not be able to differentiate between the altitudes
either.

### Testing
As we have currently no plane for testing we had to fallback to other ways of testing. Besides static testing of the
filter we also recorded multiple sequences of sensor data while riding on a bike. The data is obviously different to
the real data but can still be used for testing and debugging the filter. To be able to test the filter as good as
possible the recordings contain multiple situations such as mountains and slow and fast parts. Furthermore one of
the recording consists of a loop, this helps us to minimize the loop closing error. 
