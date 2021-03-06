//マウスのクリックで音を鳴らす
//rwMidiの改造ライブラリを利用　http://web.t-factory.jp/nicotech/applet/rwmidi_patch/rwmidi.zip
//RWMidi本家　http://ruinwesen.com/support-files/rwmidi/documentation/RWMidi.html
import processing.serial.*;
Serial myPort;
import rwmidi.*; //RWMidiの改造ライブラリの読み込み
MidiOutput output;

//variables for acceralation 
String[] _a = new String[100];
float[] a = new float[100];      // raw data.
float ax=0, ay=0, az=0;  //acceralation of x,y and z
float[] lg_x = new float[100];  //store 'x' data for 100 points.
float[] lg_y = new float[100];  //store 'y' data for 100 points.
float[] lg_z = new float[100];  //store 'z' data for 100 points.
float rate = 10;                  //rate of smoothing
float[] accel=new float[100];  //array of acceralation
float[] lg_accel = new float[100];  //buffer array of acceralation
int pos=0;
int count=0;



int vel = 100;  //Velocity（音の強さ）の設定0〜127
int program =1; //プログラムチェンジ（音色）の設定
int dev = 1; //音源の設定
int devLength = 0; //デバイスの数

int[] ch0={86,0,0,0,78,0,0,0,//-2
           76,0,0,0,0,0,0,0,
           0,0,0,0,74,0,0,0,
           78,0,0,0,0,0,0,0,
           83,0,0,0,0,0,0,0,//-1
           81,0,0,0,74,0,0,0,
           83,0,0,0,79,0,0,0,
           85,0,0,0,81,0,0,0,
           81,0,78,79,81,0,78,79,//0
           81,69,71,73,74,76,78,79,
           78,0,74,76,78,0,66,67,
           69,71,69,67,69,66,67,69,
           67,0,71,69,67,0,66,64,//1
           66,64,62,64,66,67,69,71,
           67,0,71,69,71,0,73,74,
           69,71,73,74,76,78,79,81,
           78,0,74,76,78,0,76,74,//2
           76,73,74,76,78,76,74,73,
           74,0,71,73,74,0,62,64,
           66,67,66,64,66,74,73,74,
           71,0,74,73,71,0,69,67,//3
           69,67,66,67,69,71,73,74,
           71,0,74,73,74,0,73,71,
           73,74,76,74,73,74,71,73,
           69,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0
           };
           
int[] ch1={74,0,0,0,74,0,0,0,//-2
           73,0,0,0,0,0,0,0,
           0,0,0,0,71,0,0,0,
           74,0,0,0,0,0,0,0,
           74,0,0,0,0,0,0,0,//-1
           0,0,0,0,0,0,0,0,
           74,0,0,0,0,0,0,0,
           76,0,0,0,0,0,0,0,
           62,0,0,0,0,0,0,0,//0
           57,0,0,0,0,0,0,0,
           59,0,0,0,0,0,0,0,
           54,0,0,0,0,0,0,0,
           55,0,0,0,0,0,0,0,//1
           50,0,0,0,0,0,0,0,
           55,0,0,0,0,0,0,0,
           57,0,0,0,0,0,0,0,
           57,0,54,55,57,0,54,55,//2
           57,45,47,49,50,52,54,55,
           54,0,50,52,54,0,42,43,
           45,47,45,43,45,42,43,45,
           43,0,47,45,43,0,42,40,//3
           42,40,38,40,42,43,45,47,
           43,0,47,45,47,0,49,50,
           45,47,49,50,52,54,55,57,
           74,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0,
           };
           
int[] ch2={50,0,52,0,54,0,55,0,//-2
           57,0,52,0,57,0,55,0,
           54,0,59,0,57,0,55,0,
           57,0,55,0,54,0,52,0,
           50,0,47,0,59,0,61,0,//-1
           62,0,61,0,59,0,61,0,
           62,0,0,0,0,0,0,0,
           64,0,0,0,0,0,0,0,
           57,0,0,0,0,0,0,0,//0
           52,0,0,0,0,0,0,0,
           54,0,0,0,0,0,0,0,
           49,0,0,0,0,0,0,0,
           50,0,0,0,0,0,0,0,//1
           45,0,0,0,0,0,0,0,
           50,0,0,0,0,0,0,0,
           52,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           78,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0
           };
           
int[] ch3={0,0,0,0,0,0,0,0,//-2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//-1
           0,0,0,0,0,0,0,0,
           55,0,0,0,0,0,0,0,
           59,0,0,0,0,0,0,0,
           54,0,0,0,0,0,0,0,//0
           49,0,0,0,0,0,0,0,
           50,0,0,0,0,0,0,0,
           45,0,0,0,0,0,0,0,
           47,0,0,0,0,0,0,0,//1
           42,0,0,0,0,0,0,0,
           47,0,0,0,0,0,0,0,
           45,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           57,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0
           };
           
int[] ch4={0,0,0,0,0,0,0,0,//-2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//-1
           0,0,0,0,0,0,0,0,
           50,0,0,0,0,0,0,0,
           52,0,0,0,0,0,0,0,
           50,0,0,0,0,0,0,0,//0
           45,0,0,0,0,0,0,0,
           47,0,0,0,0,0,0,0,
           42,0,0,0,0,0,0,0,
           43,0,0,0,0,0,0,0,//1
           38,0,0,0,0,0,0,0,
           43,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           38,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0
           };
           
void setup () {
  size(1200, 600);
  frameRate (120);
  //myPort = new Serial(this, "COM3", 115200);
  devLength = RWMidi.getOutputDevices ().length; //デバイスの数
  output = RWMidi.getOutputDevices () [dev].createOutput(); //デバイスの設定
  output.sendProgramChange (program); //プログラムチェンジの設定
  //デバイスリストの表示
  for (int i = 0; i < devLength; i++) {
    println ("Output Device " + i + " : " +  RWMidi.getOutputDevices () [i].getName() );
  }
  //Initialize 
  _a[0] = "0";
  _a[1] = "0";
  _a[2] = "0";
}
 
void draw () {
  
  background(210, 231, 200);
  //readData(); //store data. (now only x)

  //draw rectangles
  fill(180, 59, 42);
  stroke(180, 59, 42);
  rect(100, 300, 100, ax/30);
  rect(300, 300, 100, ay/30);
  rect(500, 300, 100, az/30);
  
  text ("Device Name: " + output.getName (), 15, 20);
  text ("Program Change: " + program, 15, 40);
  text ("Click and release MLB! ", 15, 80);
  text (count,15,100);
  text(vel,15,120);
  //text(time,15,140);
}
 
void ensou(float time){
float p2time=0;
if(count/8<pos&&time-p2time>300){
  if(count<ch0.length){
    if(count==0){
      output.sendNoteOn(0,ch0[count],vel);
      output.sendNoteOn(1,ch1[count],vel/2);
      output.sendNoteOn(2,ch2[count],vel/2);
      output.sendNoteOn(3,ch3[count],vel/2);
      output.sendNoteOn(4,ch4[count],vel/2);
    }else{
        if(ch0[count]!=0){
          output.sendNoteOff(0,ch0[count],vel);
          output.sendNoteOn(0,ch0[count],vel);
      }
      
      if(ch1[count]!=0){
          output.sendNoteOff(1,ch1[count],vel);
          output.sendNoteOn(1,ch1[count],vel);
      }
      if(ch2[count]!=0){
          output.sendNoteOff(2,ch2[count],vel);
          output.sendNoteOn(2,ch2[count],vel);
      }
      if(ch3[count]!=0){
          output.sendNoteOff(3,ch3[count],vel);
          output.sendNoteOn(3,ch3[count],vel);
      }
      if(ch4[count]!=0){
          output.sendNoteOff(4,ch4[count],vel);
          output.sendNoteOn(4,ch4[count],vel);
      }
    }
    count=count+1;
    p2time=time;
  }
 }
 pos++;
}
/*
void readData() {
  float time;
  time=millis();
  float p1time=0;
  String s="";
  while (myPort.available()>0) {
    s = myPort.readStringUntil('\n');
    _a = split(s, ' ');
    try {
      for (int i=0; i<_a.length; i++) {
        a[i] = float(_a[i]);
      }
      lg_x[0]=a[0];
      lg_y[0]=a[1];
      lg_z[0]=a[2];
    }
    catch(NullPointerException e) {
    }
    for (int j=98; j>=0; j--) {
      lg_x[j+1] = lg_x[j];
      lg_y[j+1] = lg_y[j];
      lg_x[j+1] = lg_z[j];
    }
    for (int i=0; i<rate; i++) {
      ax+=lg_x[i];
      ay+=lg_y[i];
      az+=lg_z[i];
    }
    ax=ax/rate;
    ay=ay/rate/7;
    az=az/rate;
  }
  
  for(int i=0; i<100;i++){
    lg_accel[i]=accel[i];
  }
  for(int i=0; i<99;i++){
    accel[i]=lg_accel[i+1];
    fill(180, 59, 42);
    stroke(180, 59, 42);
    text(accel[i],100,9*i+10);
    translate(150,50);
    fill(180, 59, 42);
    stroke(180, 59, 42);
    if(i+1<99){
    line((i+1)*3,lg_accel[i+1]/100,i*3,lg_accel[i]/100);
    }
    translate(-150,-50);

  }
  accel[99]=sqrt(ax*ax+ay*ay+az*az);
  
 
  text(time-p1time,300,300);  
  
  
  if(accel[98]-accel[95]>300&&accel[98]-accel[85]>2000&&accel[99]-accel[98]<0&&accel[99]>3500&&time-p1time>=3000){
    p1time=time;
    ensou(time);
  }
  text(count,200,200);
}*/
void keyPressed(){
  float time;
  time=millis();
  float p1time=0;
  if(key=='a'&&time-p1time>100){
    while(true){
      ensou(time);
      pos++;
      p1time=time;
    }
  }
}