import java.io.*;
import SimpleOpenNI.*;

SimpleOpenNI kinect; //interface to Kinect
PGraphics pg; //buffer (what the users have drawn)
final int[] j = {1, 2, 6, 7, 9, 12, 13, 15, 3, 17, 21, 18, 22, 24, 20}; //joints for which we want data
PVector[] jp = new PVector[j.length+1]; //the positions of those interesting joints, in 2d ("projective mode"), scaled to our screen size.  The last PVector is the center of the head, which we're creating.
PVector tempVec = new PVector();
final int[][] jc = { //joint connections to draw
  {1,2}, {1,5}, //neck-shoulders
  {5,6}, {6,7}, {2,3}, {3,4}, //shoulder-elbow-hand
  {9,10}, //hips
  {2,9}, {5,10}, //shoulders-hips
  {9,11}, {11,14}, //left hip-knee-foot
  {10,12}, {12,13} //right hip-knee-foot
};
int kinectWd, kinectHt;
int[] users = new int[0];
int[] cb; // colorbar, will be filled with values from pb (palettebar) in setup(). 
SimpleDateFormat formatter = new SimpleDateFormat("yyyy-MM-dd-hh-mm-ss");

//-- settings
final int pbh = 10; //palette bar height //note: does overlap with pg
final int cbh = 10; //color bar height (in pixels) //note: the colorbar does overlap the pg (drawing area)
final int sbh = 10; //size bar "height" (actually the width) (in pixels) //note: the sizebar does overlap the pg (drawing area)
//the following two numbers are the window size.  The variables (ht & wd) are the drawing area height & width
final int ht =  screen.height;
final int wd = screen.width;
int rtc = color(0); //right hand color //note: jp[7] is the coordinates of the right hand
float brushDiameter = 0;
final int[][] pb = {  //palettebar has sets of colors that can be put into colorbar. Can be of any length. (Just add and remove colors and palettes as you please.)
  {#00FF00, #00FFFF, #0000FF, #FF00FF, #FF0000, #FFFF00}, 
  {#888888, #88FF88, #88FFFF, #8888FF, #FF88FF}, 
  {#000000, #008800, #008888, #000088, #880088, #880000, #888800}
};
final int[] sb = { //size bar brush diameters. Can be of any length. (Just add and remove sizes as you please.)  If (ht/sb.length)>max(sb) they will overlap.
  5, 10, 20, 40, 60, 100
};
//--

void setup() {
  size(wd, ht); //window size
  for (int i=0;i<jp.length;i++) {
    jp[i] = new PVector();
  }
  cb = pb[0];

  kinect = new SimpleOpenNI(this, SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  kinect.setMirror(true); //keeps left on left, right on right.
  kinect.enableDepth(); //turns on IR sensing.
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL); //dunno

  kinectWd = kinect.depthWidth();
  kinectHt = kinect.depthHeight();
  frameRate(50); //frames per second
  smooth(); //draw slower but smoother.  Comment out if running too slow.

  pg=createGraphics(wd, ht, P3D); // "width" & "height" are the dimensions of the window.
  pg.beginDraw();
  pg.background(0);
  pg.noStroke();
  pg.endDraw();
}

//every frame
void draw() {
  image(pg, 0, 0);
  drawPalettebar();
  drawColorbar();
  kinect.update();
  for (int i=0;i<users.length;i++) { //loop through all of the current users; "users[i]" will refer to the id of the user we're looking at in the iteration.
    if (kinect.isTrackingSkeleton(users[i])) { //only do stuff if the kinect is tracking this user.
      updateJoints(users[i]); //change the values in jp (joint positions)
      //the following two functions simply use the values in jp, which we just changed.
      drawPaint(); //draw brush to pg
      drawSkeleton(); //draw straight to screen.
      checkPalettebar();
      checkColorbar();
    }
  }
}

void updateJoints(int userId) { //update jp (joint positions)
  for (int i=0;i<j.length;i++) {
    kinect.getJointPositionSkeleton(userId, j[i], tempVec);
    kinect.convertRealWorldToProjective(tempVec, jp[i]);
    jp[i].x = jp[i].x * wd / kinectWd;
    jp[i].y = jp[i].y * ht / kinectHt;
  }
  jp[jp.length-1].x = (jp[0].x+jp[1].x)/2; //real head position, as per our discretion.
  jp[jp.length-1].y = (jp[0].y+jp[1].y)/2;
  brushDiameter = min(jp[4].y-jp[10].y,0);
}

void drawPaint() {
  pg.beginDraw();
  //right hand
  pg.fill(rtc);
  pg.ellipse(jp[7].x, jp[7].y, brushDiameter, brushDiameter);
  pg.endDraw();
}

void drawSkeleton() {
  strokeWeight(5); 
  stroke(255);
  noFill();
  for (int i=0;i<jc.length;i++) { //draw each joint connection (limb)
    line (jp[jc[i][0]].x, jp[jc[i][0]].y, jp[jc[i][1]].x, jp[jc[i][1]].y);
  }
  ellipse(jp[7].x, jp[7].y, brushDiameter, brushDiameter); //right hand
  float headRadius = dist(jp[0].x, jp[0].y, jp[1].x, jp[1].y)*.75;
  ellipse(jp[jp.length-1].x, jp[jp.length-1].y, headRadius, headRadius);
}

void drawPalettebar() {
  int bl = wd/pb.length; //box length
  strokeWeight(3);
  stroke(0);
  for (int i=0;i<pb.length;i++) {
    fill(pb[i][0]); 
    rect(i*bl, 0, bl, pbh);
  }
}
void drawColorbar() {
  int bl = wd/cb.length; //box length
  strokeWeight(3);
  stroke(0);
  for (int i=0;i<cb.length;i++) {
    fill(cb[i]); 
    rect(i*bl, ht, bl, -cbh);
  }
}
void checkPalettebar() {
  if (jp[7].y < pbh) {
    cb = pb[constrain(floor(jp[7].x/wd*pb.length), 0, pb.length-1)];
  }
}
void checkColorbar() {
  if (jp[7].y > ht-cbh) {
    rtc = cb[constrain(floor(jp[7].x/wd*cb.length), 0, cb.length-1)];
  }
  if (jp[4].y > ht-cbh) {
    rtc = cb[constrain(floor(jp[4].x/wd*cb.length), 0, cb.length-1)];
  }
}


//kinect stuff

void onNewUser(int userId)
{
  print("onNewUser(user:" + userId + ")");
  print(" // start pose detection  -  ");
  kinect.startPoseDetection("Psi", userId);
  //update userlist
  int[] newUsers = new int[users.length+1];
  for (int i=0;i<users.length;i++) newUsers[i]=users[i];
  newUsers[users.length] = userId;
  users = newUsers;
  for (int i=0;i<users.length;i++) print(users[i] + ",");  
  println();
}
void onLostUser(int userId)
{
  print("onLostUser(user:" + userId + ")");
  //save data
  String outstring = formatter.format(new Date());
  save(outstring + ".jpg"); //take a screenshot

  //update userlist
  ArrayList users2 = new ArrayList();
  for (int i=0;i<users.length;i++) if (users[i]!=userId) users2.add(users[i]);
  users = new int[users2.size()];
  for (int i=0;i<users2.size();i++) users[i]= (Integer) (users2.get(i));
  print(" - ");
  for (int i=0;i<users.length;i++) print(users[i] + ",");  
  println();
}

void onStartPose(String pose, int userId)
{
  print("onStartPose(user:" + userId + ",pose:" + pose + ")");
  println(" // stop pose detection");
  kinect.stopPoseDetection(userId); 
  kinect.requestCalibrationSkeleton(userId, true);
}
void onEndPose(String pose, int userId)
{
  println("onEndPose(user:" + userId + ",pose: " + pose + ")");
}

void onStartCalibration(int userId)
{
  println("onStartCalibration(user:" + userId +")");
}
void onEndCalibration(int userId, boolean successfull)
{
  print("onEndCalibration(user:" + userId + ",successfull:" + successfull +")");
  if (successfull) 
  { 
    println(" // User calibrated !!!");
    kinect.startTrackingSkeleton(userId);
  } 
  else 
  { 
    print(" // Failed to calibrate user !!!");
    println(" // Start pose detection");
    kinect.startPoseDetection("Psi", userId);
  }
}

