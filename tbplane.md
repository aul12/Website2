---
layout: page
title: Toolbox Plane
permalink: /tbplane/
---

## Developing an autonomous plane
A friend and i decided to develop and build our own flightcontrol platform for a model airplane.  
We started the project in 2017 and already had multiple test flights to test different components.
Our long term goal is a fully autonomous long distance flight.

![Toolbox Plane](../assets/img/plane.jpg "Toolbox Plane"){:class="img-responsive" width="100%"}


## Plane

| The autonomous plane is build using a X-UAV Mini Talon remote controlled airplane. The airplane has a wing span of 1.3m and much space on the inside which gives us a greater flexibility when choosing and designing our electronics. It is powered by an electric motor in the rear, a LiPo-Battery provides enough charge for long flights. | ![Mini Talon](../assets/img/talon.jpg "Mini Talon"){:class="img-responsive" width="100%"} |


## Flightcontroller

| ![Flightcontroller](../assets/img/flightcontroller.jpg "Flightcontroller"){:class="img-responsive" width="100%"} | At the heart of our plane is our self-developed flight controller. It is based around a Nucleo-L432KC development board, a Bosch-Sensortec BNO055 IMU and a NXP MPL3115A2 Barometer and Altimeter. The flightcontrol is responsible for real time data processing and the subordinate feedback control, additionally it is responsible for managing our "overwrite remote control" ([PCB](https://github.com/ToolboxPlane/FlightControllerBoard), [Software](https://github.com/ToolboxPlane/FlightControllerSoftware)). |

## Power-Distribution-Board

| The power distribution board is responsible for creating all required voltage levels (5V and 3.3V) and measuring all voltages and currents, furthermore it calculates the power consumption and estimates the battery status. The board consists of three Linear Technology LTC-2946 power managment ICs and an Microchip AtMega 48 ([PCB](https://github.com/ToolboxPlane/PowerDeliveryBoard), [Software](https://github.com/ToolboxPlane/PowerDistributionBoardSoftware)). | ![PDB](../assets/img/pdb.jpg "PDB"){:class="img-responsive" width="100%"} |

## Decision Finding and Feedback-Control

| ![Feedback-Control Data](../assets/img/feedbackcontrol.jpg "Feedback-Control Data"){:class="img-responsive" width="100%"} | The decision finding and superordinate feedback control runs on a Raspberry Pi. The decision finding is implemented using a hierarchical state machine, the feedback control for the principal axis, speed and position is implemented using an distributed, cascaded PID-Control ([FlightComputer](https://github.com/ToolboxPlane/FlightComputer), [Simulink Simulation](https://github.com/ToolboxPlane/ControlSimulation)). |

## Communication

| We implemented a custom transport-layer protocol which is independent of the transmission medium, this protocol is responsible for efficient coding, error detection and routing. This protocol is used for communication between the different components on the plane (via USB) and for communication of the plane with the remote control and the base station (LoRa or WiFi). To get the maximum benefit of our custom protocol we designed our own remote control ([Protocol definition](https://github.com/ToolboxPlane/RadioControlProtocol), [Software for the Remote](https://github.com/ToolboxPlane/RadioControlSoftware), [Custom 3D-printed case for the remote](https://github.com/ToolboxPlane/RadioControlHardware)). | ![Remote](../assets/img/remote.jpg "Remote"){:class="img-responsive" width="100%"} |

