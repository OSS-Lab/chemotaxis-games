// chemotaxis model with four species
//
// This model simulates four different chemotaxis stratergies:
//   (1) no movement (red bugs)
//   (2) random movement (yellow bugs)
//   (3) movement decisions based on the current level of food (green bugs)
//   (4) movement decisions with adaptation (blue bugs)
// 
// Food is dropped in the middle of the four bug groups by pressing the spacebar.
//
// The location of each bug, its current behaviour and the level of food is has are printed to a text file "positions.txt"
//
// The simulation is ended by pressing the q key. (Note that not pressing the q-key will result in curruption of "positions.txt" as the file remains open).
// 
// author Orkun Soyer
// further edits by Alexander Darlington

//#// setup //#//

int xsize = 700;  // see below when creating the environment - in processing3 size cannot take variables.
int ysize = 700;

float decision = 0.5; // decision threshold

// food and diffusion definititions
float addFood = 0.5;
float grid[][] = new float[xsize][ysize];
float gridNext[][] = new float[xsize][ysize];
float gradFood;
float diffCoeff = 0.01;
float deltaT = 0.01;
float deltaXsq = 0.1;
int nBugs = 10;
int timeStepCounter = 0;
int tmax = 5000;

PrintWriter output;

ArrayList<bug> buglist = new ArrayList<bug>(); // create space for array of objects

// create environment and bacteria
void setup() {
  
  // create the environment
  size(700, 700);  // in Processing 3 size of board must be defined explicitly
  colorMode(RGB,10); // this command makes the colormode
  background(0,0,0); // what color the backround is
  
  // define new bugs and genotypes
  // bug(width, height, x0, y0, angle0, red, green, blue, stratergy choice, p(TumbleExit), p(TumbleEntry), speed)
  // strategyChoice: 0; no movement. 1: random movement. 2: respond to absolute food. 3: respond to change
  for(int i=0;i<nBugs;++i) {
    buglist.add(new bug(13,5,240,240,45,255,0,0,0,0.0,0.0,0));        // no movement, red
  }
  for(int i=0;i<nBugs;++i) {
    buglist.add(new bug(13,5,460,240,135,128,128,0,1,0.9,0.35,0.75));  // random movement, yellow
  }
  for(int i=0;i<nBugs;++i) {
    buglist.add(new bug(13,5,460,460,225,0,255,0,2,0.9,0.35,0.75));    // movement based on current food, green
  }
  for(int i=0;i<nBugs;++i) {
    buglist.add(new bug(13,5,240,460,315,0,0,255,3,0.9,0.35,0.75));    // movement with adaptation, blue
  }
  
  // initialise food grid with zeros
  for(int i=0;i<xsize;++i) {
   for(int j=0;j<ysize;++j) {
     grid[i][j] = 0.0;
    }
  }
  
  // open output file
  output = createWriter("positions.txt");
  
}

// simulate and draw
void draw() {
  
  //#// create food //#//
  
  int foodXstart = -1, foodXend = 0, foodYstart = -1, foodYend = 0;
  boolean dropFood = false;
  
  //// upon mouse click drop food  
  //if (mousePressed == true) {
  //foodXstart = mouseX-10; if (foodXstart < 0) {foodXstart = xsize-1;}
  //foodXend = mouseX+10; if (foodXend >= xsize) {foodXend = 0;}
  //foodYstart = mouseY-10; if (foodYstart < 0) {foodYstart = ysize-1;}
  //foodYend = mouseY+10; if (foodYend >= ysize) {foodYend = 0;}   
  //dropFood = true;
  //}
  
  // upon spacebar press drop food in centre
  if (keyPressed); {
  if (key == ' ') {
   foodXstart = 330;
   foodXend = 370;
   foodYstart = 330;
   foodYend = 370;   
   dropFood = true;
  }
  }
    
  // drop food
  if (dropFood) {
    for(int i=foodXstart;i<foodXend;++i) {
      for(int j=foodYstart;j<foodYend;++j) {
        grid[i][j] = grid[i][j] + addFood;
       }
    }
    dropFood = false;
  }
      
  // display food
  loadPixels();
  for(int i=0;i<xsize;++i) {
    for(int j=0;j<ysize;++j) {
      pixels[j*xsize+i] = color(255*grid[i][j],255*grid[i][j],255*grid[i][j]);
    }
  }
  updatePixels();  // refresh pixels for visual output
  diffusion(); // of food stuff
  
  //#// create bugs and simulate movement //#//
  for (int i = 0; i < buglist.size(); i++) {
    bug cell = buglist.get(i);  
          
    // draw the cell
    cell.display();
    
    //force it to make a decision on its "mode", based on food availability
    float food = grid[(int)cell.bugposX][(int)cell.bugposY]; 
    // gradFood = dFood / ddist
    float gradFood = (food-grid[(int)cell.bugposXPrev][(int)cell.bugposYPrev]); ///sqrt(abs(sq(cell.bugposX-cell.bugposXPrev)-sq(cell.bugposY-cell.bugposYPrev)));
    cell.decide(food, gradFood); 
    
    // tuble or swim the cell based on its mode
    if (cell.mode==1) {
      cell.swim(); // swim
      cell.display();
    }
    else {
      cell.tumble();  // tumble
      cell.display();
    }
    
    //write time step
    output.print(timeStepCounter);
    output.print("\t");
    
    // write bug id and type
    output.print(i+1);
    output.print("\t");
    output.print(cell.mode);
    output.print("\t");
    
    // write bug i location to file
    output.print(cell.bugposX);
    output.print("\t");
    output.print(cell.bugposY);
    output.print("\t");
    
    // write bug food
    output.print(grid[(int)(cell.bugposX)][(int)(cell.bugposY)]);
    output.print("\t");
        
    // line break
    output.print("\n");
    
  }
  
  // upon q press close file and exit simulation
  if (keyPressed); {
    if (key == 'q') {
      output.flush();
      output.close();
      exit();
    }
  }
  
  timeStepCounter = timeStepCounter + 1;
  if (timeStepCounter == tmax+1) {
    output.flush();
    output.close();
    exit();
  }
  
}


//#// bug and function definitions //#//

// create the class bug //
class bug {
  int bugwidth;
  float bugheight;
  float bugposX;
  float bugposXPrev;
  float bugposY; 
  float bugposYPrev;
  float bugangle;
  int mode;
  int bugred;
  int buggreen;
  int bugblue;
  int strategy;
  float pTumbleExit;
  float pTumbleEntry;
  float bugspeed;
  
  bug(int bw, float bh, float bpx, float bpy, float ba, int rd, int gn, int bl, int stgy, float pExit, float pEntry, float spd) {
    bugwidth = bw;
    bugheight = bh;
    bugposX = bpx;
    bugposXPrev = bpx;
    bugposY = bpy;
    bugposYPrev = bpy;
    bugangle = ba;
    mode = 1;
    bugred = rd;
    buggreen = gn;
    bugblue = bl;
    strategy = stgy;
    pTumbleExit = pExit;
    pTumbleEntry = pEntry;
    bugspeed = spd;
  } 
      
  // swimming behaviour
  void swim() {
    float xspeed=bugspeed*cos(radians(bugangle));
    float yspeed=bugspeed*sin(radians(bugangle));
    bugposXPrev = bugposX;
    bugposYPrev = bugposY;
    bugposX = bugposX + xspeed;
    bugposY = bugposY + yspeed;
    if (bugposX>xsize) bugposX = 0;
    if (bugposX<0) bugposX = xsize-1;
    if (bugposY>ysize) bugposY = 0;
    if (bugposY<0) bugposY = ysize-1;
  }

  // tumble behaviour 
  void tumble() {
    bugangle = bugangle + 1*random(0,20);
  }
  
  // display
  void display() {
    pushMatrix();
    translate(bugposX,bugposY);
    rotate(radians(bugangle));
    rect(0,0,bugwidth,bugheight);
    triangle(0,bugheight,0,0,4,bugheight/2);
    fill(bugred, buggreen, bugblue);
    popMatrix();
  }  
  
  //decision making
  void decide(float signal, float gradSignal) {
    
    // strategy 0 
    // no movement
    if (strategy == 0) {
      mode = 0;
    }
    
    // strategy 1 
    // random movement
    if (strategy == 1) {
      decision = (0.5+random(-0.2,0.2));
      if (decision < 0) {decision = 0;}
      if (mode == 1) {
        if (decision < pTumbleEntry) {
          mode = 0;
        }
      } else {
        if (decision < pTumbleExit) {
          mode = 1;
        }
      }
    }

    // stratergy 2 // sensing absolute value of food 
    if (strategy == 2) {
      decision = (0.5+random(-0.2,0.2))-signal;
      if (decision<0) {decision=0;}
      if (mode==1) {
        if (decision < pTumbleEntry) {
          mode=0;
        }
      } else {
        if (decision < pTumbleExit) {
          mode=1;
        }
      }
    }
  
    // strategy 3 // sensing rate of change of food
    if (strategy == 3) {
      decision = (0.5+random(-0.2,0.2))+gradSignal;
      if (decision < 0) {decision = 0;}
      if (mode == 1) {
        if (decision < pTumbleEntry) {
          mode = 0;
        }
      } else {
        if (decision < pTumbleExit) {
          mode = 1;
        }
      }
    }
  }
}


// diffusion of chemical
void diffusion() {
  float multiplier = diffCoeff*deltaT/deltaXsq;
  int qx=0, qy=0, wx=0, ex=0;
  int ax=0, ay=0, dx=0;
  int zx=0, zy=0, xx=0, cx=0;
  for(int i=0;i<xsize;++i) {
    for(int j=0;j<ysize;++j) {
      qx = i-1; if (qx < 0) {qx = xsize-1;} 
      qy = j+1; if (qy >= ysize) {qy = 0;}
      wx = i;
      ex = i+1; if (ex >= xsize) {ex = 0;} 
      
      ax = i-1; if (ax < 0) {ax = xsize-1;} 
      ay = j;
      dx = i+1; if (dx >= xsize) {dx = 0;} 
      
      zx = i-1; if (zx < 0) {zx = xsize-1;}
      zy = j-1; if (zy < 0) {zy = ysize-1;}
      xx = i;
      cx = i+1; if (cx >= xsize) {cx = 0;}
      
      gridNext[i][j] = grid[i][j]-multiplier*grid[i][j]+(multiplier*grid[qx][qy]+multiplier*grid[wx][qy]+multiplier*grid[ex][qy]+multiplier*grid[ax][ay]+multiplier*grid[dx][ay]+multiplier*grid[zx][zy]+multiplier*grid[xx][zy]+multiplier*grid[cx][zy]);
      if (gridNext[i][j] < 0.0) {gridNext[i][j] = 0.0;}
    }
  }
  float temp[][] = grid;
  grid = gridNext;
  gridNext = temp;
}