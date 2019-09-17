---
layout: post
title:  "Release of all RoboCup Software as Free Software"
date:   2019-09-13 22:00:00 +0200
categories: robocup
---

While i was still at school i participated at [RoboCup-Junior](https://junior.robocup.org/rcj-soccer-open/), most of the years in the soccer open discipline. 
Our team "Bodenseehaie" (sharks of lake constance) participated at the world cup four times from 2013 to 2016 and even won in 2016. 

The league we participated in required us to develop two robots which are able to play soccer. The robots need to be able to function completly autonomous without input from a human and shoot goals on a table sized soccer field. The video below shows our robots at the german championship in 2015.

<iframe style="width: 100%; height: calc(60vw/1.77);" src="https://www.youtube.com/embed/o5agd4SijGY" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>

Its my firm believe that all research should be freely available ([free as in freedom, not as in free beer](https://www.gnu.org/philosophy/free-sw.html)) to the public for the greater good.
Thus i made a decision which was long overdue: to release all our software as free software (licensed under [GPLv3](https://www.gnu.org/licenses/quick-guide-gplv3.en.html)). 
This not only includes our main code, but also our simulator, a desktop program for debugging and an algorithm to detect the orange ball.

## Main Code
This is the main logic and hardware abstraction for both of our robots. The software consists of the software running on our main processor, an AtXMega64A1, and the software running on our line detection PCB which was equiped with an AtMega48. The code is available now available on github: [github.com/aul12/RoboCupCode](https://github.com/aul12/RoboCupCode).

![Our robots](../../../../../assets/img/robocup-foss/robot.jpg){:class="img-responsive" width="100%"}

## Simulator
The simulator has already been free software before (available at [github.com/aul12/RoboCup-Simulation](https://github.com/aul12/RoboCup-Simulation)).
It provides an intermediate layer to run the actual robot software in the simulator and test the software without the physical robot.

![Simulator](../../../../../assets/img/robocup-foss/simulator.png){:class="img-responsive" width="100%"}

## Desktop Debugging Program
The debugging program is a desktop application written with Qt to visualize the environment as it is perceived by the robot. This helps to debug the sensor data and the postprocessing algorithms of the robot. The data is received via a serial (UART) link from the robot, in our case we used an HC06 or HC05 module to send the data over a bluetooth link. The code is available on github as well: [github.com/aul12/RobotDebug](https://github.com/aul12/RobotDebug).

![The debug software](../../../../../assets/img/robocup-foss/debug.png){:class="img-responsive" width="100%"}

## Orange Ball Detector
I only participated in RoboCup until 2016, for the competition 2017 the regulations changed to use a passive (that means orange) ball instead of the active infrared ball. As the change in regulations was anounced before, a friend and me decided to implement an algorithm for detecting the orange ball.
The detector is a combination of a conventional hue based detector and a shape based detector using the canny edge detector.
Additionally filtering and tracking is applied to improve the accuracy. The code can be found on github too: [github.com/aul12/ROBOT](https://github.com/aul12/ROBOT).

![The output of the algorithm](../../../../../assets/img/robocup-foss/orangeball.png){:class="img-responsive" width="100%"}

I hope these programs are able to help and inspire other RoboCup teams in developing their solutions. Maybe it will even motivate some teams to share more of their solutions, in the interest of completeness i have to mention FIRST RoboCup Team which published their robot in 2013 ([frtrobotik.de/roboter/opensource/](http://www.frtrobotik.de/roboter/opensource/)).

If there are any questions regarding any part of the software feel free to ping me on twitter [@fuhapaul](https://twitter.com/fuhapaul).
