int i=0;
int k=0;
ArrayList<fire_works> fireworks=new ArrayList<fire_works>();           

import oscP5.*;
import netP5.*;
 
OscP5 oscP5;
 
int posx, posy;
  
void setup () {
  size(1500,750,P3D);
  frameRate(100); 
  hint(DISABLE_DEPTH_TEST);
  blendMode(ADD);
  imageMode(CENTER);
  
  oscP5 = new OscP5(this, 10000);//自分のポート番号
  oscP5.plug(this,"getData","/test");//getDta:受け取る関数
}
 
void draw () {
  background(0,0,15);
  for(int i=0;i<fireworks.size();i++){
     fire_works art=fireworks.get(i);
     if(art.m==0){
       art.ready();
     }else{
       art.display();
       art.update();
     }

   }
   for(int i=0;i<fireworks.size();i++){
     fire_works art=fireworks.get(i);
     if(art.centerPosition.y-art.radius>height){
       fireworks.remove(i);
     }
   }
  
  if(k<i){
    fireworks.add(new fire_works(80));
    k=k+1;
  }
}


//キーボードから鳴らす場合
void keyPressed(){
  if(key=='a'){
  i=i+1;
  }
}


PImage createLight(float rPower,float gPower,float bPower){
  int side=32;
  float center=side/2.0;
  
  PImage img=createImage(side,side,RGB);
  
  for(int y=0;y<side;y++){
    for(int x=0;x<side;x++){
      float distance=(sq(center-x)+sq(center-y))/10.0;
      int r=int((255*rPower)/distance);
      int g=int((255*gPower)/distance);
      int b=int((255*bPower)/distance);
      img.pixels[x+y*side]=color(r,g,b);
    }
  }
  return img;
}
class fire_works{
  int num=256;
  
  PVector centerPosition=new PVector(random(width/8,width*7/8),random(height/2,height*4/5),random(-100,100));
  PVector velocity=new PVector(0,-18,0);
  PVector accel=new PVector(0,0.6,0);
  float colorchange=random(0,5);
  PImage img;


    
  float radius;
  float pos_radius;
  
  PVector[] posFirePosition=new PVector[num];
  PVector[] firePosition=new PVector[num];
  
  float cosTheta;
  float sinTheta;
  float phi;
  
  int s1=0,s2=0;
  
  int  m=0;
  
  fire_works(float r){
    radius=r;
  }
  
  void ready(){
      while(s1<num){
      cosTheta = random(0,1) * 2 - 1;
      sinTheta = sqrt(1- cosTheta*cosTheta);
      phi = random(0,1) * 2 * PI;
      firePosition[s1]=new PVector(radius * sinTheta * cos(phi),radius * sinTheta * sin(phi),radius * cosTheta);
      posFirePosition[s1]=firePosition[s1]; 
      firePosition[s1]=PVector.mult(firePosition[s1],1.12);
      s1++;
      }
      m++;
      if(colorchange>=4){
   img=createLight(0.9/*random(0.5,0.8)*/,random(0.2,0.5),random(0.2,0.5));
  }else if(colorchange>3){
    img=createLight(random(0.2,0.5),0.9,random(0.2,0.5));
  }else if(colorchange>2){
    img=createLight(random(0.2,0.5),random(0.2,0.5),0.9);
  } else {
    img=createLight(random(0.5,0.8),random(0.5,0.8),random(0.5,0.8));
  }
  }
  
  void display(){
    while(s2<num){
      pushMatrix();
      translate(centerPosition.x,centerPosition.y,centerPosition.z);
      strokeWeight(1);
      beginShape(LINES);
      stroke(0);
      vertex(posFirePosition[s2].x,posFirePosition[s2].y,posFirePosition[s2].z);
      stroke(200, 100);
      vertex(firePosition[s2].x,firePosition[s2].y,firePosition[s2].z);
      endShape();
      translate(firePosition[s2].x,firePosition[s2].y,firePosition[s2].z);
      image(img,0,0);
      popMatrix();
      posFirePosition[s2]=firePosition[s2]; 
      
      firePosition[s2]=PVector.mult(firePosition[s2],1.015);
      s2++;
    }
  }
  
  void update(){
    //pos_radius=radius;
    //radius+=2;
    radius=dist(0,0,0,firePosition[0].x,firePosition[0].y,firePosition[0].z);
    centerPosition.add(velocity);
    velocity.add(accel);
    s1=0;
    s2=0;
  }
}

public void getData(int reci) {
  i = reci;
}