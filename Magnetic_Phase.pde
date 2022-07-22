/*
This program simulates the spins of a crystal latice as temperature changes. 
It uses the the Ising model, thus spins can eithe be up (1) or down (-1). 
It uses the Monte Carlo Simulation with the Metropolis Algorithm to simulate the lattice.
Credit to David Bellanger and Barber for their implimentation of the algorithm.
Enjoy!
-Deniz Gencer
*/

import controlP5.*;
ControlP5 cp5;
Slider tempS, csizeS, speedS;
Bang runSimB;
Textlabel FPST, FPSLabelT, AverSpinT, CalculPerST;

//User Definable variables (assigned when runSimB is pressed)
float temp = 1.5;
int speed = 1000000;
int csize = 1;
//Simulation Height and Width, window will be larger to accomodate GUI
int sHeight = 800;
int sWidth = 800;
//Variables for Cell array
int cols, rows;
int[][] cells;
//Temperature lookup table array
float[] lt = new float[9];


void settings() {
  size(sWidth, sHeight + 200);
}

//Runs once when program opens
void setup() {
  surface.setTitle("2D ISING Barber/Belanger/Gencer");
  //Initalizes and Draws GUI in window
  makeGUI();
  //Clears and turns it black
  background(0);
  //Makes framerate (virtually) uncapped)
  frameRate(400);
  //initializes cell array and randomizes it
  initCells();
  //calculates temperature lookup table
  lt = calcLookupTable(temp);
}

//Runs once every frame
void draw() {
  //Clears Background (used for GUI)
  background(0);
  //Updates the cell array (speed) times
  for (int i = 0; i < speed; i++) {
    //updates random cell
    updateCellSpin(int(random(rows)), int(random(cols)));
  }
  // uses the cells[] data to draw a grid to the pixel buffer
  drawCells();
  //updates all the values in the text
  updateText();
}

//initializes cell data, taking into account cell and window size then randomizes the array
void initCells() {
  //calculates the number of rows and columns based on the window and cell size
  cols = floor(sHeight/csize);
  rows = floor(sWidth/csize);
  //declares the cells[] array with the variables above as height and width
  cells = new int[cols][rows];
  //randomizes array
  randoCells();
}

//Randomizes the entire cells[] array (random structure has mean spin of about 10^-4)
void randoCells() {
  //iterates over every cell
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j<rows; j++) {
      //sets every cell = 1
      cells[i][j] = 1;
      //flips every cell with 50% chance
      if (random(1) < 0.5) {
        cells[i][j]=-cells[i][j];
      }
    }
  }
}

//update given cell's spin using the Metropolis algorithm, credit to David Belanger and Barber for implementation
void updateCellSpin(int x, int y) {
  //stores the position of adjesant cells, if cells are on border it loops back around to other side of window
  int xp = x+1;
  int xm = x-1;
  if (x==rows-1)xp=0;
  if (x == 0)xm = rows -1;

  int yp = y+1;
  int ym = y-1;
  if (y==cols-1)yp=0;
  if (y == 0)ym = cols-1;
  //cells can have one of 9 states, the state is calculated with the following function:
  int ien = 4 + cells[y][x] * (cells[ym][x] + cells[yp][x] + cells[y][xm] + cells[y][xp]);
  //the state is then looked up in table and if it greater than a random number between 0 & 1, the spin of the cell is flipped
  if (lt[ien]>random(1)) {
    cells[y][x]=-cells[y][x];
  }
}

//converts cell[] variable to tiles to display by writing into the pixel buffer, it is done seperately from updating function to allow for very high (1M/frame) calculations per frame without too much impact to performance 
void drawCells() {
  //loads the pixel buffer into memory
  loadPixels();
  //iterates over every pixel in simulation window
  for (int i = 0; i < sHeight; i++) {
    for (int j = 0; j<sWidth; j++) {
      //maps data in cells[] to tiles on screen using the map() function, taking the cell size into account
      switch (cells[int(map(i, 0, sHeight, 0, sHeight/csize))][int(map(j, 0, sWidth, 0, sWidth/csize))]) {
      // converts spin to color
      case -1:
        pixels[i*sWidth+j]=color(0,0,0);
        break;
      case 1:
        pixels[i*sWidth+j]=color(255,255,255);
        break;
      }
    }
  }
  //loads pixel buffer onto screen
  updatePixels();
}

//called when Run button is pushed, changes the values of the variables under the hood to reflect those of the sliders, re-intits cells[] and recalculates lookup table
public void Run() {
  //Changes csize to reflect slider value
  csize = int(csizeS.getValue());
  //re-init cells[] with new size
  initCells();
  //Changes temp to reflect slider value
  temp = tempS.getValue();
  //recalculat lookup table
  lt = calcLookupTable(temp);
  //changes the speed to reflect the slider value
  speed = int(speedS.getValue());
}

//Calculates the lookup table for a given temperature, credit to David Belanger and Barber for implementation
float[] calcLookupTable(float temperature) {
  //lookup table array is declared
  float[] ex = new float[9];
  //9 states are calculated 
  for (int i = 0; i < 9; i++)
  {
    float arg = -2. * (i - 4.) / temperature;
    ex[i] = exp(arg);
  }
  //array is returned
  return ex;
}

//creates all the GUI objects
void makeGUI() {
  cp5 = new ControlP5(this);
  //Add Buttons
  runSimB = cp5.addBang("Run").setPosition(20, sHeight + 20).setFont(createFont("Georgia", 16, true));
  //Add Sliders
  tempS = cp5.addSlider("Temperature (kt)").setPosition(20, sHeight+70).setSize(200, 20).setRange(0.01, 10).setValue(temp).setFont(createFont("Georgia", 16, true));
  csizeS = cp5.addSlider("Cell Size (px)").setPosition(20, sHeight + 100).setSize(200, 20).setRange(1, 15).setValue(csize).setNumberOfTickMarks(15).setDecimalPrecision(0).setFont(createFont("Georgia", 16, true));
  speedS = cp5.addSlider("Speed (particles per frame)").setPosition(20, sHeight + 130).setSize(200, 20).setRange(1, 1500000).setValue(speed).setDecimalPrecision(0).setFont(createFont("Georgia", 16, true));
  //Add Text
  FPST = cp5.addFrameRate().setInterval(10).setPosition(540, sHeight+70).setFont(createFont("Georgia", 16, true));
  FPSLabelT = cp5.addTextlabel("FPSLabelT").setText("FPS:").setPosition(500, sHeight+70).setFont(createFont("Georgia", 16, true));
  AverSpinT = cp5.addTextlabel("AverSpinT").setText("").setPosition(500, sHeight+130).setFont(createFont("Georgia", 16, true));
  CalculPerST = cp5.addTextlabel("CalculPerST").setText("").setPosition(500, sHeight+100).setFont(createFont("Georgia", 16, true));
}

//Updates all the values for text
void updateText() {
  //gets average spin of cells using by getting the mean of the array
  AverSpinT.setStringValue("Average Spin: "+ arrAverage2D(cells));
  //gets calculations/s by multiply the FPS by the number of cells calculated per frame (speed)
  CalculPerST.setStringValue("Calculation /s " + (float(int(FPST.getStringValue())*speed))/1000000+"M");
}

//calculates a given 1D array's mean
float arrAverage(int[] arr) {
  float total = 0;

  for (int i=0; i<arr.length; i++) {
    total += arr[i];
  }
  return total/arr.length;
}

//calculates a given 2D array's mean (assumes rows & columns are uniform)
float arrAverage2D(int[][] arr) {
  float total = 0;

  for (int i = 0; i < arr.length; i++) {
    for (int j = 0; j<arr[0].length; j++) {
      total += arr[i][j];
    }
  }
  return total/(arr.length*arr[0].length);
}
