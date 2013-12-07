ml-js
====

Machine Learning library for Node.js

Status : Under development


## Installation
ml-js depends on [FANN](http://leenissen.dk/fann/wp/) (Fast Artificial Neural Network Library) witch is a free, open source and high performence neural network library

To build great app with it : 
* Make sure you glib2 is installed  : `sudo apt-get install glib2.0`
* make sure pkg-config is installed : `sudo apt-get install pkg-config`
* make sure cmake is installed      : `sudo apt-get install cmake`
* Install FANN : 
  * download  [here](http://leenissen.dk/fann/wp/download/)
  * unzip
  * goto to FANN directory
  * run `cmake .` and `sudo make install`
  * run `sudo ldconfig`

Finally, you should be able to install all npm dependancies :  `npm install`
