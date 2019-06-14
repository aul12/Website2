---
layout: post
title:  "Toolbox-Plane PCBs"
date:   2019-04-29 22:49:00 +0200
categories: tbplane embedded
---

After having several problems with our last PCB-Stack used in the [Toolbox-Plane](https://aul12.me/tbplane) (in no particular order: large size, problems with the mcu not starting, non standardized platform) we decided to design three new PCBs for our plane. 

## Power-Delivery-Board

|Even tho we where quite happy with our old PDB we still had some minor bugs to fix: the I²C-Bus was missing pull-up resistors, the power-monitoring ICs needed a small wire to enable their clock and our polarity protection blew up on the first launch (attempt). To standardize our PCBs, we swapped the AtMega48 for a much larger AtMega2560 which we can also use in the flightcontroller and navboard. This also enables the PDB to directly send data to the flightcomputer instead of sending it via the flightcontroller which reduces complexity (and hopefully faults). Some other changes included a different 5V and 3.3V regulators for reduced cost and size and better output connectors (XT30 instead of Pinheaders)|![PDB](../../../../../assets/img/tbplane-pcb/pdb.jpg){:class="img-responsive" width="100%"}The new pdb (without processor and power connectors)|

## Flightcontroller

|![FC](../../../../../assets/img/tbplane-pcb/fc.jpg){:class="img-responsive" width="100%"}The new flightcontroller (without processor)|The changes made to the flightcontroller where all about reducing complexity (which hopefully leads to greater reliability). Instead of the much more powerful STM32-L432KC we now use an AtMega2560 which is enough for our tasks and should work more reliably. Additionally we moved the Altimeter to the Navboard, simply because we do not have real-time constraints on this data and can thus collect it on the flightcomputer.|


## Navboard
This is one more PCB than we had before: we added a "Navigation-Board" which simplifies our flightcontroller and flightcomputer. The Nav-Board is home to our altimeter, our ultrasonic distance sensor, the gps and the lora-communication-module. This makes the software on the flightcomputer less dependent on running on the actual pi (it can now run on any POSIX compliant system) and simplifys our flightcontroller. To meet our deadline we decided to focus primarily on the two neccessary PCBs (PDB and FC), this is why the navboard is not ready yet.

## KiCad

|Because we already had expercience with Eagle, all of our old PCBs where designed using Eagle. Due to the limitations of eagle (namely plated holes for the USB-C Connector) we decided for these PCBs to design them in KiCad. In contrast to eagle kicad is free software (libre and gratis) additionally it is available as a package on most distributions (updating Eagle is quite a hassle). |![KiCad](../../../../../assets/img/tbplane-pcb/kicad.png){:class="img-responsive" width="100%"}KiCad Features a very nice 3D-Viewer|


## Soldering
To reduce cost and size we placed some components which had been on seperate breakout boards directly on the PCB. Especially the Bosch-Sensortec BNO-055 saved us a lot of space and external components (the Adafruit-Breakout has an Level-Shifter included so it was necessary for us to add a second level-shifter on our PCB) but also required us to use the reflow oven in our local makerspace.

|![Old vs New](../../../../../assets/img/tbplane-pcb/oldVsnew.jpg){:class="img-responsive" width="100%"}| ![New](../../../../../assets/img/tbplane-pcb/new.jpg){:class="img-responsive" width="100%"}|  
| The old pcbs (on the left side) and the new pcbs (right). On the top row is the PDB, on the bottom row the FC | The top (left) and bottom (right) of the PDB (top) and FC (bottom) |

|![New](../../../../../assets/img/tbplane-pcb/stencil.jpg){:class="img-responsive" width="100%"} |![Paste](../../../../../assets/img/tbplane-pcb/paste.jpg){:class="img-responsive" width="100%"}|
| All PCBs, stencils and XT-60 connectors | Applying the solder paste on the PCB using the stencil |

|![Pick and Plane](../../../../../assets/img/tbplane-pcb/pnp.jpg){:class="img-responsive" width="100%"} |![Oven](../../../../../assets/img/tbplane-pcb/oven.jpg){:class="img-responsive" width="100%"}|
| Placing the components on the FC  | Reflow soldering the PDB |

