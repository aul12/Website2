---
layout: page
title: Portfolio 
permalink: /portfolio/
---
# Portfolio
## Carolo Cup
I participated for two years at the [Carolo-Cup](https://wiki.ifr.ing.tu-bs.de/carolocup/en/carolo-cup) with Team "Spatzenhirn".
We scored the third place in 2018 and won the Cup in 2019.
I developed the road-marking detection, the sign detection and the obstacle detection for use in the vehicle. I 
am also responsible for the software structure and the computer infrastructure.

![Carolo-Cup](../assets/img/carolo.jpg "Carolo-Cup"){:class="img-responsive" width="100%"}

## RoboCup Junior
From 2011 to 2016 i participated in [RoboCup Junior](https://junior.robocup.org/about/) (Soccer-Open League), with Team "Bodenseehaie" as the software team lead.
In 2015 we won the german championship and participated at the worldcup in Hefei, China. In 2016 we won the overall worldcup with our self developed robots.

To extend our testing capabilities i developed a complete end-to-end simulator using Electron and Web-GL. This allowed us to test software indepent of the hardware. The complete simulator is available on [Github](https://github.com/aul12/RoboCup-Simulation), licensed under GPLv3.

![RoboCup](../assets/img/robocup.jpg "RoboCup"){:class="img-responsive" width="100%"}

## SerialToolbox
During the initial phase of software development for a microcontroller i often feel the need to view data which the microcontroller sends via UART to a computer. 
This is why i developed SerialToolbox, to not only be able to send and receive data but also to do this using a multitude of different representations.
SerialToolbox is inspired by the program HTerm (which was sadly discontinued in 2008). It is written in modern C++17 using QT, the software is completly 
opensource (Licensed under GPLv3) and available on [GitHub](https://github.com/aul12/SerialToolbox).

![SerialToolbox](../assets/img/SerialToolbox.png "SerialToolbox"){:class="img-responsive" width="100%"}

## eduJS
A simple HTML-WYSIWYG-Editor with a JS editor for creating simple webapps using HTML5 and Javascript. I developed this programm as a project for my former school, they were interested in quickly building apps in class to read sensor data. The code is available on [GitHub](https://github.com/aul12/eduJS) (Licensed under GPLv3), i also gave a talk on this application (in german), the slides are available on [Google
Drive](https://docs.google.com/presentation/d/16bmZYIa_k7B3Fv3K5naTQL9vzd_MBaoVq_4Ty2uxOfY/edit?usp=sharing).

## Tests using an AMG-8833 thermal imager
This was an test to detect the presence and movement of humans using an [AMG8833](https://na.industrial.panasonic.com/products/sensors/sensors-automotive-industrial-applications/grid-eye-infrared-array-sensor/series/grid-eye-high-performance-type-amg8833/ADI8005/model/AMG8833) thermal imager. 
The data is received via udp from an esp8266, then optimal upsampling using lanczos interpolation is applied. For background surpression a fast temporal median filter is used. 

Due to the  very low resolution of the sensor (8x8 Pixel) and the quite low temperature difference of humans compared to the background this project was not successful but the code is still available on [GitHub](https://github.com/aul12/Amg8833Tests) (licensed under GPLv3).

## Dungeon
A 3D Dungeon Game written in Javascript using WebGL, this was a rewrite of a game i had programmed in school using C# (in 2D). The code is available on [GitHub](https://github.com/aul12/Dungeon) (licensed under GPLv3), the game is also hosted on [Github-Pages](https://aul12.github.io/Dungeon).

