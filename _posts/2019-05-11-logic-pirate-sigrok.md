---
layout: post
title:  "Using the Dangerous Prototypes Logic Pirate with Sigrok and Pulseview"
date:   2019-05-11 22:49:00 +0200
categories: embedded
---

After having used the [Dangerous Prototypes Logic Pirate](http://dangerousprototypes.com/docs/Logic_Pirate) with the recommended [Open Logic Sniffer application](https://github.com/jawi/ols) for many years i decided to try a different client for a couple of reasons: primarily OLS is quite an old software, the latest release is from 2015 and everytime i wanted to use it i had to configure my computer to use java 8. 

![Logic Pirate](../../../../../assets/img/logic-pirate-sigrok/logicpirate.jpg){:class="img-responsive" width="100%"}

I quickly decided on trying [sigrok](https://sigrok.org/), primarily because it has a large community and is in active development, furthermore i liked their modular approach (libsigrok as a backend, libsigrokdecode for protocol-decoding and sigrok-cli or pulseview as a frontend) and open license (GPLv3). Sadly the Logic Pirate is not directly supported by sigrok because it only implements a subset of the [SUMP-Protocol](https://www.sump.org/projects/analyzer/protocol/).
With a little bit of work it is still possible to use sigrok and the Logic Pirate together, but because i didn't find any good tutorial i decided to write this tutorial.

## Patching sigrok vs flashing a new firmware
I first tried to patch libsigrok to set reasonable defaults for the values not reported by the logic analyzer, mainly based on this [bug report](https://sigrok.org/bugzilla/show_bug.cgi?id=1287#c2). I did this by first trying to merge the patch into the latest version of sigrok (0.6.0), then i tried to apply the patch to the version the patch was written for (0.5.0) but both lead to the same result: libsigrok forgot most of the available devices and i still couldn't use the analyzer.

Next i tried to flash a [fixed firmware](http://dangerousprototypes.com/forum/viewtopic.php?f=58&t=7073) to the Logic-Pirate, which turned out to be quite a challenge.

## Flashing a new firmware (without windows)
After having downloaded the new firmware i tried to follow the [tutorial on the official logic pirate website](http://dangerousprototypes.com/docs/Logic_Pirate#Entering_Update_Mode) but this requires a windows programm for flashing the firmware as i have (luckily) no windows device to hand i looked for a crossplatform utility for flashing a PIC32 microcontroller with USB-Bootloader. There are two options: using the [proprietary microchip
IDE](https://www.microchip.com/mplab/mplab-x-ide), which for me didn't work (after downloading 600mb). The second option is to use a clone of the windows utility which is available on some ancient [google code site](https://code.google.com/archive/p/pic32ubl-qt/), and needs some fixes first to actually compile, the fixed version can be found on my [GitHub](https://github.com/aul12/pic32ubl-qt), together with the installation instructions. After compiling this program i was very pleased to find an identical (and working) interface to the official application.

![The interface of the program](../../../../../assets/img/logic-pirate-sigrok/flash.png){:class="img-responsive" width="100%"}
To flash the firmware download the new firmware, either from the [forum](http://dangerousprototypes.com/forum/download/file.php?id=12846), or from [my mirror](http://aul12.me/assets/logicpirate.zip).
Disconnect the logic-analyzer from your PC, on the device connect the `TEST` pin to the `3.3V` pin using an female-female jumper cable, then plug it in your computer, the red LED should be flashing at about 2Hz.

Next open the pic32ubl-qt program, on the left  select USB and select the Logic Pirate (the IDs can be found by running `lsusb` and searching for the microchip device). On the right side click connect, next select the `.hex` firmware file you downloaded and click on `Erase-Program-Verify`. That's it you should now be running the new firmware

I decided to use the opportunity and also upgrade from the stock 40MHz-Samplerate firmware to not officially supported 60MHz-Samplerate firmware. With this new software i'm now able to use sigrok and pulseview with the logic pirate.

![Pulseview](../../../../../assets/img/logic-pirate-sigrok/pulseview.png){:class="img-responsive" width="100%"}
