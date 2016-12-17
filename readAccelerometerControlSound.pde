import processing.serial.*;
import ddf.minim.*;

Serial myPort;  // Create object from Serial class
String val;      // Data received from the serial port

FloatList Xs, Ys, Zs;
float xoffset, yoffset, zoffset;
float filteredX, filteredY, filteredZ;
float filterVar = 0.08;


Minim minim;
AudioPlayer song;
AudioPlayer noise;
float myVolume;
float noiseVol;
int interval;


void setup() 
{

  size(700, 700);
  //  pixelDensity(displayDensity());
  Xs = new FloatList();
  Ys = new FloatList();
  Zs = new FloatList();
  printArray(Serial.list());
  String portName = Serial.list()[7];
  myPort = new Serial(this, portName, 9600);

  minim = new Minim(this);
  song = minim.loadFile("douwei_sm.mp3", 512);
  noise = minim.loadFile("Burned Mind-Wolf Eyes.mp3", 512);
  //noise = minim.loadFile("princess.mp3", 512);
  noiseVol = 0;
  myVolume = 0;
  interval = 0;
  song.play();
  song.loop();
  noise.play();
  noise.setGain(-40);
}

void draw()
{
  background(244);

  if ( myPort.available() > 0) {  // If data is available,
    val = myPort.readStringUntil(' ');

    if (val!=null) {
      val = trim(val);
      String[] results = split(val, ",");
      if (results.length == 3) {

        int x = Integer.parseInt(results[0]);
        int y = Integer.parseInt(results[1]);
        int z = Integer.parseInt(results[2]);


        //        println(x+","+y+","+z);

        if (Xs.size()>2) {
          float lastX = Xs.get(Xs.size()-1);
          filteredX = (x - lastX) * filterVar + lastX;
        }
        if (Ys.size()>2) {
          float lastY = Ys.get(Ys.size()-1);
          filteredY = (y - lastY) * filterVar + lastY;
        }
        if (Zs.size()>2) {
          float lastZ = Zs.get(Zs.size()-1);
          filteredZ = (z - lastZ) * filterVar + lastZ;
        }
        Xs.append(filteredX);
        Ys.append(filteredY);
        Zs.append(filteredZ);

        if (Xs.size() > width) {
          Xs.remove(0);
        }

        if (Ys.size() > width) {
          Ys.remove(0);
        }

        if (Zs.size() > width) {
          Zs.remove(0);
        }

        if (Xs.size()>2 && Ys.size() > 2 && Zs.size() > 2) {
          xoffset = Xs.get(Xs.size()-1) - Xs.get(Xs.size()-2);
          yoffset = Ys.get(Ys.size()-1) - Ys.get(Ys.size()-2);
          zoffset = Zs.get(Zs.size()-1) - Zs.get(Zs.size()-2);
        }
      }
    }
  }

  //println(xoffset+" , " +yoffset + "  , " + zoffset);
  fill(0);
  text("x change: " + xoffset, 10, 20);
  text("y change: " + yoffset, 10, 40);
  text("z change: " + zoffset, 10, 60);
  text("volume: "+ myVolume, 10, 80);

  if (abs(zoffset) > 3) {
    int skipframe = (int)abs(zoffset) * 20;
    song.skip(skipframe);
  }
  
//  if (abs(xoffset) > 3) {
//    song.shiftGain(myVolume, myVolume + (xoffset), 1000);
//    myVolume += xoffset * 0.1;
//  }

  if (abs(yoffset) > 2) {
    noiseVol = yoffset;
  } else {
    if (noiseVol > -30) {
      noiseVol-=0.5;
    }
  }

  noise.setGain(noiseVol);

  //Draw x,y,z line graph

  strokeWeight(1);
  noFill();

  stroke(255, 0, 0);
  beginShape();
  for (int i = 0; i < Xs.size (); i++) {
    vertex(i, Xs.get(i)   + 100);
  }
  endShape();
  stroke(0, 255, 0);
  beginShape();
  for (int i = 0; i < Ys.size (); i++) {    
    vertex(i, Ys.get(i)  + 100);
  }
  endShape();

  stroke(0, 0, 255);
  beginShape();
  for (int i = 0; i < Zs.size (); i++) {    
    vertex(i, Zs.get(i)  + 100);
  }
  endShape();
}


void keyPressed()
{
  //  if ( key == 'r' )
  //  {
  //    myVolume = 0;
  //  }
}
