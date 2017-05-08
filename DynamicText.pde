/*======================================================================
| Project: Processing Environment implementation of 'The Coding Train' 
|          Coding Challenge #59: Steering Behaviors
| Author:  Steven Eiselen, University of Arizona Computer Science
|          Daniel Shiffman, NYU / The Coding Train (see Source below)
| Source:  The Coding Train 'Coding Challenge #59: Steering Behaviors',
|          link to video/code: www.youtube.com/watch?v=4hA7G3gup-4
+-----------------------------------------------------------------------
| Description: Implements several physics based movement behaviors for a
|              set of particles whose positions are defined by the edge 
|              vertices of characters of an input string of text.
+-----------------------------------------------------------------------
| Version Info:
|  > MM/DD/YY - Original <xor> [List of Changes]
*=====================================================================*/

/*----------------------------------------------------------------------
|>>> STRUCT DECLARATIONS
+-----------------------------------------------------------------------
| > PFont myFont             = User-defined font
| > ArrayList<Vehicle>points = Contains the vehicles i.e. points
+---------------------------------------------------------------------*/
PFont myFont;
ArrayList<Vehicle>points = new ArrayList<Vehicle>();

/*----------------------------------------------------------------------
|>>> TRIGGERS AND SETTINGS
+-----------------------------------------------------------------------
| > String inputText = Points will define the edges of these chars
| > int pointOffset  = Desired distance between each point
| > int pointOffHalf = Half the value of pointOffset as integer
| > int circleSize   = Diameter of the ellipses that represent points
| > int inputTxtSize = Size of the input text, via textSize(...) call
| > color fillColor  = Desired color of the points
| > boolean doOnce   = Restricts setUpPoints() to be called only once
+---------------------------------------------------------------------*/
String  inputText    = "Sample\nText";
int     pointOffset  = 20;
int     pointOffHalf = pointOffset/2;
int     circleSize   = 10;
int     inputTxtSize = 200;
color   fillColor    = color(0,120,255);
boolean doOnce       = false;

/*----------------------------------------------------------------------
|>>> Function setup 
+---------------------------------------------------------------------*/
void setup(){
  size(1200,600);
  myFont = loadFont("Verdana-48.vlw"); textFont(myFont, 48);
  ellipseMode(CENTER);
} // Ends Function setup

/*----------------------------------------------------------------------
|>>> Function draw 
+-----------------------------------------------------------------------
| Implementation Notes:
|  > The doOnce conditional is needed to set up the points on the first 
|    frame. Initialized to false, it allows entry on frame 1; wherein
|    function setUpPoints() is called; followed by doOnce being assigned
|    the value true, locking the conditional from further access.
+---------------------------------------------------------------------*/
void draw(){
  
  if(!doOnce){setUpPoints();doOnce=true;}
  
  background(0); fill(fillColor); // Per-Frame VFX setting calls
  
  for(Vehicle p : points){ p.update();} // Update set of points
  for(Vehicle p : points){ p.render();} // Render set of points
  
} // Ends Function draw


/*----------------------------------------------------------------------
|>>> Function setUpPoints 
+-----------------------------------------------------------------------
| Purpose: Calculates the coordinates of points that represent the edges
|          of each char in the input string text; such that each point
|          is at least pointOffset distance from every other point. This
|          function attempts to do (in a very hacky way) what the p5.js 
|          function 'font.textToPoints(...) function does; as Processing 
|          does not have its own implementation of this functionality.
| Source:  The for loop and code within that draws the 'outline' of the
|          input string was derived from this link:
|          forum.processing.org/two/discussion/16700/how-to-outline-text
+-----------------------------------------------------------------------
| Implementation Notes: This function encompasses six main phases...
|  
| > PHASE 1 - DISPLAY EDGES OF INPUT STRING: We need to display only the
|   edges of the input string. Processing by itself does not support the
|   ability to do this, so we instead render several offset versions of
|   the input string, fill colored white against a black background. We 
|   then set the fill color to black and call text once more on the real
|   location of the input text. Together: this creates the effect of the
|   input text rendering only its edge outlines with a stroke weight of 
|   around 2 pixels, depending on current hardcoded input.
|    
|  > PHASE 2 - MARK GRID WITH INPUT STRING EDGES: We get the color value
|    for each pixel. Because the text appears as white edges against a
|    black background, we query if the color value is greater than some
|    grayscale value (hardcoded to 120 in the original version of this
|    program). This is to accomodate anti-aliasing and other processing
|    effects that do not render parts of the text outline as color(255).
|    If the color of the pixel does imply it encompasses an edge, its
|    corresponding coordinate is marked with the value '1' in a 2D array
|    called grid[] that represents the display window's pixels.
|    
|  > PHASE 3 - REDUCE NUMBER OF VERTEX CANDIDATES: Phase 2 marked a lot
|    of grid cells as encompassing a text edge. We reduce the amount of
|    candidate vertices by implementing a 'smoothing' technique similar
|    to cellular automata algorithms used in prodedural generation. 
|    
|    We iterate through each pixel represented by cells in grid[]. If 
|    the pixel it represents was marked '1', and its value in another 
|    2D array called tempGrid[] is zero, we inspect the neighborhood 
|    of pointOffset square pixels surrounding the current pixel. 
|    
|    All neighbors whose distance from the current pixel is less than 
|    or equal to the radius of the point offset are marked as '-1' in
|    tempGrid[], meaning that they will not be evaluated or considered
|    as vertices. This is how we enforce the pointOffset rule for all 
|    marked grid cells - so only those within pointOffset distance from
|    each other become vertices in the final return set.
|    
|  > PHASE 4 - DEFINE NEW GRID BASED ON VERTICES: We redefine grid[]
|    such that only cells marked with the value '1' in tempGrid[] will
|    retain the value '1' in the redefined grid[]. This is the pruning
|    step that prepares grid[] for assignment into Vehicle vertices.
|    
|  > PHASE 5 - POPULATE LIST OF VERTICES: Trivial - any cell in grid[]
|    with a value of '1' will have its cell coordinates define a new
|    Vehicle object that gets added to the ArrayList called 'points'.
|      
|  > PHASE 6 - PRINT STATS / HIDE IMAGE: Prints the total number of
|    Vehicles a.k.a. edge vertices appended to ArrayList 'points';
|    and then draws a rectangle colored black to hide the set of
|    text primitives called in Phase 1.
+-----------------------------------------------------------------------
| Improvement Ideas / TTD: A lot, but I wanted to get a basic working
| version of this build with supporting documentation on the algorithms
| developed up on my GitHub to share with the community. So today's wrap
| up energy went there instead. Ergo: the TTD list is also a TTD, lol!
+---------------------------------------------------------------------*/
void setUpPoints(){
  
  int[][] grid = new int[height][width];
  int[][] tempGrid = new int[height][width];
  
  /*################################################
  |>>> PHASE 1 - DISPLAY EDGES OF INPUT STRING
  ################################################*/ 
  textAlign(CENTER,CENTER);textSize(inputTxtSize);background(0);fill(255);
  for(int x = -1; x < 2; x++){text(inputText,(width/2)+x,(height/2));text(inputText,(width/2),(height/2)+x);}
  fill(0);text(inputText,width/2,height/2);
  
  /*################################################
  |>>> PHASE 2 - MARK GRID WITH INPUT STRING EDGES
  ################################################*/
  loadPixels();
  for(int i=0; i<height; i++){
    for(int j=0; j<width; j++){
      if(pixels[i*width+j] > color(120)){
        grid[i][j] = 1;
      }           
    }
  }
  
  /*################################################
  |>>> PHASE 3 - REDUCE NUMBER OF VERTEX CANDIDATES
  ################################################*/  
  for(int i=0; i<height; i++){
    for(int j=0; j<width; j++){ 
      if(grid[i][j] == 1 && tempGrid[i][j]==0){
        for(int rV=i-pointOffHalf+1; rV<i+pointOffHalf; rV++){
          for(int rH=j-pointOffHalf+1; rH<j+pointOffHalf; rH++){
            if(dist(i,j,rV,rH)<=pointOffHalf){
              if(rV>=0&&rV<height&&rH>=0&&rH<width){
                tempGrid[rV][rH]=-1;
              }
            }
          }
        }
        tempGrid[i][j]=1;
      }
    }
  }

  /*################################################
  |>>> PHASE 4 - DEFINE NEW GRID BASED ON VERTICES
  ################################################*/  
  for(int i=0; i<height; i++){
    for(int j=0; j<width; j++){
      if(tempGrid[i][j]==1){grid[i][j]=1;}
      else{grid[i][j]=0;}
    }
  }
  
  /*################################################
  |>>> PHASE 5 - POPULATE LIST OF VERTICES
  ################################################*/    
  int numPts = 0;
  for(int i=0; i<height; i++){
    for(int j=0; j<width; j++){
      if(grid[i][j] == 1){
        numPts++;
        points.add(new Vehicle(j,i));
      }
    }
  }
  
  /*################################################
  |>>> PHASE 6 - PRINT STATS / HIDE IMAGE
  ################################################*/  
  println("Total # Points = " + numPts);
  fill(0); rect(0,0,width,height); // Don't show the image to the user!

} // Ends Function setUpPoints

/*----------------------------------------------------------------------
|>>> Class Vehicle
+-----------------------------------------------------------------------
| Purpose: Implements the Vehicle agent class in two major ways:
|
|          1) Encompasses location of a point representing the edge of
|             the outline of a character of text from the input string.
|
|          2) Performs several movement behaviors based on positional 
|             information assigned to the object and/or mouse input.
| Source:  The code in this class is almost entirely based on code and
|          algorithms discussed by Daniel Shiffman in The Coding Train
|          video called "Coding Challenge #59: Steering Behaviors". I
|          made some minor adaptations from his implementation, mostly
|          for refactoring code into Java syntax. The link to the video
|          is here: www.youtube.com/watch?v=4hA7G3gup-4
+-----------------------------------------------------------------------
| State Variables and Structs:
|  > pos = position
|  > vel = velocity
|  > acc = acceleration
|  > tar = target
+-----------------------------------------------------------------------
| Improvement Ideas / TTD:
|  > Lots, mainly towards adding new behaviors, allowing modification of
|    state values, and switching between behavior modes. But I wanted to
|    get my Processing version on GitHub, so we'll say 'T.B.D.' for now.
+---------------------------------------------------------------------*/
class Vehicle{

  PVector pos,vel,acc,tar;
  int size = circleSize;
  float maxSpeed = 10;
  float maxForce = 0.3;
  
  public Vehicle(int x, int y){
    this.pos = new PVector(random(width),random(height));
    this.tar = new PVector(x,y);
    this.vel = new PVector(0,0);
    this.acc = new PVector(0,0);  

    this.vel.x = random(5);
    this.vel.y = random(5);
  } // Ends Constructor

  void update(){
    pos.add(vel);
    vel.add(acc);
    acc.mult(0);
    behaviors();
  } // Ends Function update
  
  void render(){
    ellipse(pos.x,pos.y,size,size); 
  } // Ends Function render

  void behaviors(){
    //acc.add(seekBehavior(tar)); 
    PVector arrive = arriveBehavior(tar);
    PVector flee   = fleeBehavior(new PVector(mouseX,mouseY));
    
    arrive.mult(1);
    flee.mult(5);
    
    acc.add(arrive);
    acc.add(flee);
     
  } // Ends Function behaviors
  
  PVector arriveBehavior(PVector target){
    PVector desired = PVector.sub(target,pos);
    float dist = desired.mag();
    float speed = maxSpeed;
    if(dist<100){speed = map(dist, 0, 100, 0, maxSpeed);}
    desired.setMag(speed);
    PVector steer = PVector.sub(desired,vel);
    steer.limit(maxForce);
    return steer;
  } // Ends Function arriveBehavior
  
  PVector seekBehavior(PVector target){
    PVector desired = PVector.sub(target,pos);
    desired.setMag(maxSpeed);
    PVector steer = PVector.sub(desired,vel);
    steer.limit(maxForce);
    return steer;
  } // Ends Function seekBehavior
  
  PVector fleeBehavior(PVector target){
    PVector desired = PVector.sub(target,pos);
    float dist = desired.mag();
    if(dist<50){
      desired.setMag(maxSpeed);
      desired.mult(-1);
      PVector steer = PVector.sub(desired,vel);
      steer.limit(maxForce);
      return steer;
    }
    else{
      return new PVector(0,0);
    }
  } // Ends Function fleeBehavior
} // Ends Class Vehicle