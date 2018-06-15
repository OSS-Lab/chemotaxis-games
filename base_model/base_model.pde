// chemotaxis basic model
//
// This simple model simulates a single bug swimming in an environment without food. 
// Food can be dropped from the mouse with a left click. 
// Close the simulation by pressing the q key.
//
// author Orkun Soyer
// further edits by Alexander Darlington

// set up variables
bug oss;

int xsize = 700;
int ysize = 700;

float addFood = 0.5;
float decision = 0.5;

// create food grid
float grid[][] = new float[xsize][ysize];
float gridNext[][] = new float[xsize][ysize];

float diffCoeff = 0.01;
float deltaT = 0.01;
float deltaXsq = 0.1;

PrintWriter output;

// create environment and bacteria
void setup() {
  
  // create the environment
  size(700, 700);  // in Processing 3 size of board must be defined explicitly
  colorMode(RGB,10); //This command makes the colormode.
  background(0,0,0); //What color the backround is.
  
  // creates an object of class bug called <oss> with given properties
  oss = new bug(13,5.0,350,350,45.0,255,255,255,0.9,0.38,0.5); //creats a object from class bug called oss with given properties.
  
  // initialise food grid with zeros
  for(int i=0;i<xsize;++i) {
   for(int j=0;j<ysize;++j) {
     grid[i][j] = 0.0;
    }
  }
    
}

// simulation and draw
void draw() {

  int foodXstart = -1, foodXend = 0, foodYstart = -1, foodYend = 0;
  boolean dropFood = false;
  
  // upon mouse click create coordinates for food drop
  if (mousePressed == true) {
    foodXstart = mouseX-10; if (foodXstart < 0) {foodXstart = xsize-1;}
    foodXend = mouseX+10; if (foodXend >= xsize) {foodXend = 0;}
    foodYstart = mouseY-10; if (foodYstart < 0) {foodYstart = ysize-1;}
    foodYend = mouseY + 10; if (foodYend >= ysize) {foodYend = 0;}   
    dropFood = true;
  }
  
  // add food to space i,j
  if (dropFood) {
    for(int i=foodXstart;i<foodXend;++i) {
      for(int j=foodYstart;j<foodYend;++j) {
        grid[i][j] = grid[i][j] + addFood;
       }
    }
  }
  
  // allow food to diffuse and update colors
  diffusion();
  loadPixels();
  for(int i=0;i<xsize;++i) {
    for(int j=0;j<ysize;++j) {
      pixels[j*xsize+i] = color(255*grid[i][j],0,0);
    }
  }
  updatePixels();
  
  // draw object oss
  oss.display();

  diffusion(); // of food stuff
   
  // chemotaxis stratergy // sensing current food
  decision = (0.5+random(-0.2,0.2))-grid[int(oss.bugposX)][int(oss.bugposY)];
  
  // if decision is negative set to 0
  if (decision<0) {decision=0;}
  
  // if currently swimming then do we enter tumbling?
  if (oss.mode==1) {
    if (decision<oss.pTumbleEntry) {
      oss.mode=0;  // tumble model
    }
  }
  // else if we are tumbling do we stop?
  else {
    if (decision<oss.pTumbleExit) {
      oss.mode=1;  // swim model
    }
  }
 
  // take action outlined in oss.model tumble or swim  
  if (oss.mode==1) {
    oss.swim(oss.bugspeed); // swim
  }
  else {
    oss.tumble();  // tuble
  }
    
  // upon q press close file and exit simulation
  if (keyPressed); {
    if (key == 'q') {
      exit();
    }
  }
  
}

// bug and function definitions //

// create the class bug //
class bug {
  int bugwidth;
  float bugheight, bugposX, bugposY, bugangle;
  int mode;
  int bugred, buggreen, bugblue;
  float pTumbleExit, pTumbleEntry, bugspeed;
  
  bug(int bw, float bh, float bpx, float bpy, float ba, int rd, int gn, int bl, float pExit, float pEntry, float spd) {    bugwidth = bw;
    bugheight = bh;
    bugposX = bpx;
    bugposY = bpy;
    bugangle = ba;
    mode = 1;
    bugred = rd;
    buggreen = gn;
    bugblue = bl;
    pTumbleExit = pExit;
    pTumbleEntry = pEntry;
    bugspeed = spd;
  } 
  
  // swimming behaviour
  void swim(float speed) {
    float xspeed=speed*cos(radians(bugangle));
    float yspeed=speed*sin(radians(bugangle));
    bugposX = bugposX + xspeed;
    bugposY = bugposY + yspeed;
    if (bugposX>xsize) bugposX = 0;
    if (bugposX<0) bugposX = xsize;
    if (bugposY>ysize) bugposY = 0;
    if (bugposY<0) bugposY = ysize;
  }

  // tumble behaviour 
  void tumble() {
    bugangle = bugangle + 1*random(0,16);
  }
  
  // display
  void display() {
    pushMatrix();
    translate(bugposX,bugposY);
    rotate(radians(bugangle));
    rect(0,0,bugwidth,bugheight);
    triangle(0,bugheight,0,0,4,bugheight/2);
    popMatrix();
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