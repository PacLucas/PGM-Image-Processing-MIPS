# PGM-Image-Processding-MIPS
<h1 align="center">
  <img src="download.png" alt="MIPS" width=700>
</h1>

<p align="center">Image Processing using MIPS 32 </p>

<p align="center">
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License MIT">
  </a>
</p>

## Abstract
  The background model calculation is used in large
to detect movements from
tactics. There are several methods studied, many use
of complex calculations to achieve maximum accuracy in the
definition of background, other methods are more
simple to be implemented as the average
of pixels through a sequence of images.

  The idea of the pixel mean method is to use as a base
several sequential images of a still camera in these
images are read each pixel and with it is averaged
between the same pixels of each image. At the end it is generated
an output with the average of pixels and thus achieving
get the background template.
In this work the method of the average is approached, having its
assembly implementation of MIPS-32. In it the program
performs the reading of a sequence of images from a
camera, these images may have the format
.PGM or .PPM, and with this a new
with the calculation of the background template.
  
