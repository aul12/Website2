---
layout: post
title:  "Using PostmarketOS on my Tablet for Lecture Notes"
date:   2020-04-28 22:00:00 +0200
categories: uni
---

I still own one of the original Samsung Galaxy Tab 10.1 tablets, the old one which has been released in 2011.
Obviously it does not receive any official android updates anymore, and there are not many custom ROMs available,
for a good reason: the performance of the tablet is not sufficient for a recent android version.
As our lectures for the university a purely digital this year i had the need to annotate the slides available as
there are no printouts of the scripts available. Thus i decided to revive my old tablet for writing notes 
and annotating PDFs.

![PostmarketOS on the tablet](../../../../../assets/img/pmos-setup.jpg){:class="img-responsive" width="100%"}

I decided to try [postmarketOS](https://postmarketos.org/), it is a Alpine Linux based distribution which can be
installed on a variety of different android devices. This means i have access to the whole Linux ecosystem and the
advantage of the tiny Alpine Linux base which needs way less resources than android.

## Installing postmarketOS
For installing postmarketOS i followed the official guide available in the 
[postmarketOS wiki](https://wiki.postmarketos.org/wiki/Samsung_Galaxy_Tab_10.1%22_(samsung-p4wifi)#Installation).
As the partition layout on my tablet is broken since i had to reflash the operating system to the stock samsung OS
using Odin i have only a small root partition (approx. 1GB). This limits the size of the image i can flash onto
the tablet. Thus i decided to install no desktop environment during the installation to keep the image size small.

## Installing and configuring XFCE
After installation i installed a desktop interface, i decided to use XFCE, as
the tablet does not support Wayland (at least not with hardware acceleration),
and XFCE provides the customation options to properly use it with a touch screen.

As the device does not have a hardware keyboard i used the 
[USB Networking](https://wiki.postmarketos.org/wiki/USB_Network) option for this:
if the tablet is connected via USB to a computer it acts as a network device and
can be accessed via SSH:
```bash
ssh user@172.16.42.1
```
on the device XFCE can then be installed by running
```bash
sudo apk add postmarketos-ui-xfce4
```
after restarting the device will boot into the XFCE desktop environment.

### Setup
First i changed the panel height to 40 pixels and added a shortcut to the onscreen keyboard, more details on the 
on-screen Keyboard below.
In the window manager settings i changed the theme to "default-hdpi" to get larger UI elements, and of course
i selected a dark theme.

## On-Screen-Keyboard
Like i stated above my tablet does not have a hardware keyboard, thus i need a on-screen keyboard if i want to type something.
It should be noted that i seldomly type something as most of my notes are handwritten,
so i do not use the keyboard very often.

I tried a variety of keyboards, but in the end i decided to use matchbox-keyboard.
It provides everything required but nothing more, so it is ideal for the rare occasion
in which i have to type something, as it starts quickly.
Sadly it does not open automatically when clicked on a text field, like it is the case on most mobile operating systems.

As the default configuration has a large home button at the side i changed the configuration to remove the buttons. 
The configuration can be found under [aul12.me/assets/keyboard.xml](/assets/keyboard.xml), 
the `xml` file needs to be copied to `~/.matchbox/keyboard.xml`.

## Taking notes
The main use case for my tablet is anotating slides given as PDF files and writing notes for exercises.
Thus i need an application which allows me write on PDF files and also allows me to generate new PDF files.
I decided to use xournal, as it fullfills all requirements. There is a newer fork of xournal, xournalpp, but
it does not officially support Alpine Linux on ARM systems.

### Pen-Input
I tried multiple input methods, first my finger, then a cheap touch pen, finally i settled on a more premium pen,
which has two different tips. I chose a pen from [amazon](https://www.amazon.de/-/en/gp/product/B073GX9C3J/ref=ppx_yo_dt_b_asin_title_o00_s00?ie=UTF8&psc=1)
(i am not afilliated, i just like the pen).


## Syncing files on the tablet
As i want the option to view the annotated PDFs on my laptop and immediatly see all PDFs on the tablet.
I added two small aliases to my `.zshrc` file to sync my `Documents` directory:
```bash
alias tablet-upload="function _tablet-upload(){rsync -auPh --delete ~/Documents tablet:~}; _tablet-upload"
alias tablet-download="function _tablet-download(){rsync -auPh tablet:~/Documents/ ~/Documents}; _tablet-download"
```

