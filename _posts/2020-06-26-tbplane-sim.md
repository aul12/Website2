---
layout: post
title:  "Toolbox-Plane Update - Part 2: Simulation, Si and More"
date: 2020-06-26 20:00:00  +0200
categories: tbplane
---
As a result of the Corona pandemic i had a lot of time available during the period between the winter and the summer
semesters. Some of this time was spent by implementing new features for our [Toolbox-Plane](http://aul12.me/tbplane/)
flight computer. The flight computer is a Rasperry Pi which runs all high-level aspects of the plane such as
sensors fusion, route planning and some parts of the feedback-control. Additionally it is the centre of our
communication network: the flight computer communications with the flight controller, the power distribution board, 
the primary remote and the base station.

This is part 2 of the update, covering our new airframe, our library for providing unit safe code and our simulation
environment.

## New Airframe
Our old airframe, the Mini Talon was bought in the spring of 2017 and testing, especially in the early stages with
manual control, involved lots of crashes and hard landings. Thus we had to fix the airplane multiple times, in the end
it consisted primarily of hot glue and duct tape. This greatly reduced the reliability of the plane and made testing
difficult. Additionally, during the initial build, we decided to glue to wings onto the fuselage, this made transport
difficult. Furthermore the space inside the plane became quite limited and access to the components was very limited.
Thus we decided to switch to a new, larger airframe. We decided on the FX-79 Buffalo flying wing, which provides ample
space on the inside. Due to the corona situation we where not able to assemble the complete plane and test the plane,
this will be done as soon as we have access to our local makerspace.

## Si and C++-20
All of the flight computer code is written in C++ to be able to write fast but also safe software. To add another
layer of safety, beyond simple type safety, we implemented our own unit-library. This library requires for every
type to have an associated unit and then checks, during compile time, if an operation is valid and of what type
the result is. For example: adding a number with unit meter to a number of unit second is malformed and will
throw a compiler error, on the other hand multiplying a number of unit meter with a number of unit second is completly
valid and will yield a number with unit meter\*second.

As code:
```c++
auto m = 1_meter;
auto s = 1_second;

auto error = m + s; // Compiler error
auto correct = m * s; // Compiles, m has the correct type
```

To achieve this a template class `Si<m, kg, s, A, K, MOL, CD, T>` is used. The first seven template arguments are
the exponents of the respective units, the last argument is the underlying numeric type. The units used above
(with underlying type `float`) are represented as:
```c++
using meter = Si<1, 0, 0, 0, 0, 0, 0, float>;
using second = Si<0, 0, 1, 0, 0, 0, 0, float>;
```
to simplify type conversions all scalar values are represented by `Si` types as well:
```c++
using scalar = Si<0, 0, 0, 0, 0, 0, 0, float>;
```
This makes the interaction of scalar values with values with unit easy and intuitive, but there are some problems that
arise when interacting with libraries which do not use `Si`, especially when converting from and to `Si` units.

For example the following expression is malformed:
```c++
scalar s = 1.0F;
```
simply because the constructor of `Si` is marked `explicit` to avoid unintentional conversions for non scalar type. 

Additionally there are problems when converting the other
way, assuming a function `void f(float)` which is provided by a library, in this case the expression:
```
scalar s{1.0F};
f(s);
```
is malformed as well because `Si::operator T()` is `explicit` for the same reasons as above.

So what we want to achieve is for both the constructor and the `operator T()` to be only `explicit` if and only
if one of the exponents is not equal to zero. Luckily for us C++-20 added a nice little feature, often refered
to as `explicit(bool)` ([P0892R2](http://www.open-std.org/jtc1/sc22/wg21/docs/papers/2018/p0892r2.html)), which makes
it possible to enable/disable the explicit based on (compile-time) predicate.

Using this feature we can improve our functions, for example for the constructor:

```c++
static constexpr bool isScalar = (m==0 && kg == 0 && s == 0 && A == 0 && K == 0 && MOL == 0 && CD == 0);

constexpr explicit(!isScalar) Si(T val) noexcept;
```
for this we require a recent compiler with (at least partial) support for C++-20. When using GCC this means at least
version 9 (see [en.cppreference.com/w/cpp/compiler_support](https://en.cppreference.com/w/cpp/compiler_support)).
As this compiler is not available on the current version of Raspbian GCC was compiled from source.

For the full documentation of the library see the github repository: [teamspatzenhirn/SI](https://github.com/teamspatzenhirn/SI).

## Simulation
By choosing a flying wing instead of a more conventional plane design we lost two degrees of freedom when designing
our controller: the ailerons and elevators are combined and there is no yaw control. Thus there was the necessity
to update our controller. The general concept remains the same for now: the flightcontroller runs the controller
for pitch and roll and the flightcomputer does the trajectory planning and controls the heading, altitude and
speed. This cascaded PID controller is easy to implement, fast during execution and provides reasonably good results
with minor tuning. A point that is especially important considering we have only limited testing opportunities.

To extend our testing capabilitites, especially now where can not test at all i decided to extend our simulator used
for controller tuning to be able to find a good tune for the first tests without being able to fly the plane.
Another nice advantage of the simulator is that we can quickly test new controller types without having to risk the
plane. Obviously this all depends on a good simulator which reflects the reality as good as possible. Thus is decided
to port our current simulator from Simulink to python and extend it by using a better model.

### Modelling
To make modelling easier the model was split into multiple subsystems: the inputs are first split, so to say 
demultiplexed, for the different axis. Then most of the dynamics is handled for the axis separatly, only in the last
step the results of the subsystems are joined to form the complete plane state.

The model is based on the forces which are generated by the actuators (flaps and the motor). As the plane is modelled
as a pointmass, thus first all forces need to be converted to equivalent forces (include torque forces) which influence
this point mass. From these forces the acceleration (both translation and rotational), velocity and positions can be
calculated.

### Parameter Estimation
Most of the parameters used for the model can be measured directly, for example the dimensions and the weight. For 
other the frontal and wing area, which are required for drag and lift calculations, a picture with a known scale has
been taken. The area can then be measured as pixels in this image and then converted using this scale.

The moment of inertia can be calculated when measuring the angular position over time when torque is applied. I.e.
a known weight is placed at a known position on the wing of the plane. The plane hangs freely and thus is able to
rotate. When recording this rotation the angle at each time step can be calculated, from these angles the angular
velocity and the angular acceleration can be estimated. Given the angular acceleration and the known torque the
moment of inertia can be calculated.

![](../../../../../assets/img/tbplane-sim/front.jpg){:class="img-responsive" width="49%"}
![](../../../../../assets/img/tbplane-sim/side.jpg){:class="img-responsive" width="49%"}

