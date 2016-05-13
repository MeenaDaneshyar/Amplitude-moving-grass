//In this sketch Processing is connecting to PD via OSC to recieve the amplitude data and maps it to coordinates of the amount of bend in the grass. 
//The grass is drawn in 3D space with the bendamount being placed on the Z axis.



import netP5.*;
import oscP5.*;

int numberofblades = 5625; // the number of blades of grass, should be a square number
float squarelength = sqrt(numberofblades); // square root of the number of blades of grass is the length of each side of the square
float [] grassrootsx = new float[numberofblades]; // to store the X, Y and Z coordinates of where the "roots" (the bottom) of the blades of grass are
float [] grassrootsy = new float[numberofblades];
float [] grassrootsz = new float[numberofblades];
float [] grasstipsz = new float [numberofblades]; // to store the z coordinates of the tips of the blades of grass, because the tips are going to bend
float [] grassheights = new float[numberofblades]; // to store the heights of the blades of grass, so that they are not the same


float amplitude=0; // to store the amplitude data from OSC
float bendamount=0; // to store how much the blades should bend
float [] spacing = new float[numberofblades];

color[] greens = new color [30]; // to store 30 random shades of green

// For osc
OscP5 osc;
NetAddress remoteLocation;

void setup(){
  size(600,400,P3D); // set processing up to render in 3D
  background(255);
  noFill(); // stops processing from filling in the curve shape
  
  for(int i = 0; i<greens.length; i++){ //loop through the colours array
    greens[i] = color(random(0,15),random(150,220),random(10,40)); // fill the array with random shades of green
  }
  for(int i = 0; i<numberofblades; i++){
    spacing[i] = random(4,12);
  }
  // set up osc
  osc = new OscP5(this,12000);
  remoteLocation = new NetAddress("127.0.0.1",12000);
  
  for(int i = 0; i<numberofblades;i++){ // loop through the blades of grass
    grassheights[i] = random(100,150); // give every blade a random height between 100 and 150
  }
  
  for(int i=0; i<numberofblades; i++) { // loop through the blades of grass again
    grassrootsx[i] = (i%squarelength)* spacing[i]; // the x coordinates increase as a loop from 1 to the length of the square over and over again, and are then multiplied by the spacing distance
    grassrootsy[i] = height; // the roots of the grass are all at the bottom of the screen
    grassrootsz[i] = grasstipsz[i] = -(i/squarelength)*spacing[i]; // generates each number an amount of times equal to squarelength and sets the grass z spacing according to this
    println("X: " + grassrootsx[i] + "  Y: " + grassrootsy[i] + "  Z: " + grassrootsz[i]); // print out the coordinates for debugging
  }  
}


void draw(){
  background(255);
  lights();
  rotateX(-0.3); // effectively moves the camera upwards so that we can see over the field

  bendamount = map(amplitude,-70,12,0,-200); // map the values from pd to an amount the grass should bend
  
  for(int i=0; i<numberofblades; i++){
   grasstipsz[i] = grassrootsz[i] + bendamount; // apply the bend amount to the tips of the grass 
  }
 
  for(int i=0; i<numberofblades;i++){ // loop through all the blades of grass
    stroke(greens[int(random(30))]); // pick a random colour from the array of greens
    
    // Draw the blade of grass as a curve
    curve(grassrootsx[i],grassrootsy[i],grassrootsz[i],grassrootsx[i],grassrootsy[i],grassrootsz[i],grassrootsx[i],height-grassheights[i],grasstipsz[i],grassrootsx[i],height-grassheights[i],grasstipsz[i]);
  }
}


void oscEvent(OscMessage theOscMessage){ // from the OSCP5Message example in the OSCP5 library
  if(theOscMessage.checkAddrPattern("/first")==true){
    amplitude = theOscMessage.get(0).floatValue();
    return;
  }
}