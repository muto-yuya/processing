//加速度センサのポート
import processing.serial.*;
Serial myPort;

//音量出力用のポート
import rwmidi.*;
MidiOutput output;

//open sound controlのライブラリを追加する（必須）
import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myRemoteLocation1;
OscMessage myMessage1 = new OscMessage("/test1");
NetAddress myRemoteLocation2;
OscMessage myMessage2 = new OscMessage("/test2");

//加速度センサからの数値
String[] _a = new String[100];
float[] a = new float[100];         //生データ
float ax=0, ay=0, az=0;             //x,y,zの加速度
float[] lg_x = new float[100];      //100個分のxの加速度を保存
float[] lg_y = new float[100];      //100個分のyの加速度を保存
float[] lg_z = new float[100];      //100個分のzの加速度を保存
float rate = 10;                    //加速度の平均に使う過去の加速度の数(スムージング)
float[] accel=new float[100];       //100個分の加速度
float[] lg_accel = new float[100];  //加速度のバッファ

int pos=0;

//外部ファイル出力用
PrintWriter outwrite;
           
int program = 1; //プログラムチェンジ（音色）の設定音色
int dev = 1;                    //音源の設定
int devLength = 0;              //デバイスの数
int count=0;                    //現在の音符の位置
int i=1;                        //最初から今までトータルの拍数     
int fr=0;                       //最初から今までの経過時間(単位はframeRate)
int pfr=0;                      //最後の音符が鳴ってからの経過時間(単位はframeRate)
int p2fr=0;                     //最後の拍からの経過時間(単位はframeRate)
float[] interval={20,20,20};
int[] vel={100,100,100};        //Velocity（音の強さ）の設定0〜127　音の強さ

//楽譜(song of joy)
int[] ch0={0,0,0,0,
           78,0,78,0,79,0,81,0,//1
           81,0,79,0,78,0,76,0,
           74,0,74,0,76,0,78,0,
           78,0,0,76,76,0,0,0, 
           78,0,78,0,79,0,81,0,//2
           81,0,79,0,78,0,76,0,
           74,0,74,0,76,0,78,0,
           76,0,0,74,74,0,0,0, 
           76,0,76,0,78,0,74,0,//3
           76,0,78,79,78,0,74,0,
           76,0,78,79,78,0,76,0,
           74,0,76,0,69,0,78,0,
           78,0,78,0,79,0,81,0,//4
           81,0,79,0,78,0,76,0,
           74,0,74,0,76,0,78,0,
           76,0,0,74,74,0,0,0,
           };
           
int[] ch1={0,0,0,0,
           74,0,74,0,76,0,78,0,//1
           78,0,76,0,74,0,73,0,
           69,0,69,0,73,0,74,0,
           74,0,73,0,73,0,0,0,
           74,0,74,0,74,0,74,0,//2
           74,0,74,0,74,0,0,0,
           66,0,66,0,73,0,74,0,
           73,0,0,69,69,0,0,0,
           69,0,69,0,69,0,0,0,//3
           69,0,69,0,69,0,0,0,
           69,0,0,0,70,0,0,0,
           0,0,0,0,0,0,74,0,
           74,0,74,0,74,0,74,0,//4
           74,0,74,0,74,0,0,0,
           66,0,66,0,73,0,74,0,
           73,0,0,69,69,0,0,0,
           };
           
int[] ch2={0,0,0,0,
           69,0,69,0,69,0,69,0,//1
           69,0,69,0,69,0,69,0,
           0,0,0,0,69,0,69,0,
           69,0,67,0,67,0,0,0,
           0,0,0,0,0,0,0,0,//2
           0,0,0,0,0,0,0,0,
           0,0,0,0,67,0,69,0,
           67,0,0,66,66,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,69,0,
           0,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0,
           0,0,0,0,67,0,69,0,
           67,0,0,66,66,0,0,0,
           };
           
int[] ch3={0,0,0,0,
           50,0,0,62,62,0,0,62,//1,
           57,0,0,57,57,0,0,57,
           54,0,54,0,52,0,50,0,
           57,0,0,57,57,0,0,57,
           62,0,0,62,62,0,0,62,//2
           62,0,0,62,62,0,0,0,
           57,0,57,0,57,0,57,0,
           57,0,0,50,50,0,0,0,
           61,0,57,0,62,0,59,0,//3
           61,0,57,0,62,0,59,0,
           61,0,57,0,54,0,58,0,
           59,0,56,0,61,0,0,0,
           62,0,0,62,62,0,62,0,//4
           62,0,0,62,62,0,0,0,
           57,0,57,0,57,0,57,0,
           57,0,0,50,50,0,0,0,
           };
           
int[] ch4={0,0,0,0,
           38,0,0,57,57,0,0,57,//1
           45,0,0,45,45,0,0,45,
           42,0,42,0,40,0,38,0,
           45,0,0,45,45,0,0,45,
           50,0,0,0,60,0,60,0,//2
           59,0,0,59,58,0,0,0,
           45,0,45,0,45,0,45,0,
           45,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,52,0,57,0,0,0,
           50,0,0,0,60,0,60,0,//4
           59,0,0,59,58,0,0,0,
           45,0,45,0,45,0,45,0,
           45,0,0,0,0,0,0,0,
           };

int[] ch5={0,0,0,0,
           0,0,0,50,50,0,0,50,//1
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//2
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//3
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,//4
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           0,0,0,0,0,0,0,0,
           };
           
           
void setup () {
  size(1200, 600);
  frameRate (100);
  
  //加速度センサの設定
  myPort = new Serial(this, "COM3", 115200);
  
  //外部出力ファイルの名前
  outwrite = createWriter("writer.txt");
  
  //音声出力の設定
  devLength = RWMidi.getOutputDevices ().length;            //デバイスの数
  output = RWMidi.getOutputDevices () [dev].createOutput(); //デバイスの設定
  output.sendProgramChange (program);                       //プログラムチェンジの設定
  //デバイスリストの表示
  for (int i = 0; i < devLength; i++) {
    println ("Output Device " + i + " : " +  RWMidi.getOutputDevices () [i].getName() );
  }
  
  oscP5 = new OscP5(this,12000);//自分のポート番号
  myRemoteLocation1 = new NetAddress("10.208.182.35", 10000);//IPaddress,相手のポート番号
  myRemoteLocation2 = new NetAddress("10.208.182.35", 10001);//IPaddress,相手のポート番号
  
}
 
void draw () {
  background(210, 231, 200);
  text(i,300,300);
  text(count,300,310);
  text(interval[2],300,320);
  text(vel[2],300,340);
  readData();
  ensou();
  fr++;   //経過時間の更新
}

//音符を鳴らす
void ensou(){
  while(count/2<i&&fr-pfr>=interval[2]){  //音符間の時間が(=fr-pfr)interval[2] 1拍で音符2つ分鳴らすのでcount/2<i

    if(count<ch0.length){  //countが楽譜の範囲にあるとき(out of range を防ぐ)
      
      if(count<4){
        /*
        output.sendNoteOn(0,ch0[count],vel[2]);
        output.sendNoteOn(1,ch1[count],vel[2]);
        output.sendNoteOn(2,ch2[count],vel[2]);
        output.sendNoteOn(3,ch3[count],vel[2]);
        output.sendNoteOn(4,ch4[count],vel[2]);
        output.sendNoteOn(5,ch4[count],vel[2]);
        */
        }else{
          //0以外の場合は前回の音を消し、今回の音を鳴らす
          if(ch0[count]!=0){
            
            output.sendNoteOn(0,ch0[count],vel[2]);
        }
        if(ch1[count]!=0){
            
            output.sendNoteOn(1,ch1[count],vel[2]);
        }
        if(ch2[count]!=0){
            
            output.sendNoteOn(2,ch2[count],vel[2]);
        }
        if(ch3[count]!=0){
            
            output.sendNoteOn(3,ch3[count],vel[2]);
        }
        if(ch4[count]!=0){
            
            output.sendNoteOn(4,ch4[count],vel[2]);
        }
        if(ch5[count]!=0){
           
            output.sendNoteOn(5,ch5[count],vel[2]);
        }
      }
      count=count+1;//音符の位置を一つ進める
    }
    pfr=fr;//最後に音符が鳴った時間を更新
  }
  
}

//キーボードから鳴らす場合
void keyPressed(){
  if(key=='a'){
  i=i+1;
  OscMessage myMessage1 = new OscMessage("/test1");
  myMessage1.add(i);//add message
  oscP5.send(myMessage1, myRemoteLocation1); 
  
  interval[0]=interval[1];
  interval[1]=interval[2];
  interval[2]=(fr-p2fr)*0.35+interval[1]*0.05;//過去2つの加速度に重みをつけて変化を滑らかにする
  if(interval[2]>35){
    interval[2]=35;
  }
  
  p2fr=fr;
  }
  
  //リセット
  if(key=='r'){
    count=0;                    //現在の音符の位置
    i=1;                        //最初から今までトータルの拍数     
    fr=0;                       //最初から今までの経過時間(単位はframeRate)
    pfr=0;                      //最後の音符が鳴ってからの経過時間(単位はframeRate)
    p2fr=0;                     //最後の拍からの経過時間(単位はframeRate)
    interval[0]=20;
    interval[1]=20;
    interval[2]=20;
    vel[0]=100;        //Velocity（音の強さ）の設定0〜127　音の強さ
    vel[1]=100;
    vel[2]=100;
  }
}

void readData() {
  //arduinoからの加速度読み込み
  String s="";
  if(myPort.available()>0) {
    s = myPort.readStringUntil('\n');
    _a = split(s, ' ');
    try {
      for (int i=0; i<_a.length; i++) {
        a[i] = float(_a[i]);
      }
      //最新の加速度
      lg_x[0]=a[0];
      lg_y[0]=a[1];
      lg_z[0]=a[2];
    }
    catch(NullPointerException e) {
    }
    //バッファの更新番号が小さいほど新しい
    for (int j=98; j>=0; j--) {
      lg_x[j+1] = lg_x[j];
      lg_y[j+1] = lg_y[j];
      lg_x[j+1] = lg_z[j];
    }
    //スムージング(rateの個数分、過去の加速度との平均をとり変化を滑らかにする)
    for (int i=0; i<rate; i++) {
      ax+=lg_x[i];
      ay+=lg_y[i];
      az+=lg_z[i];
    }
    ax=ax/rate;
    ay=ay/rate/7;//y軸だけ感度が高いので7で割る
    az=az/rate;
   }
  //加速度のグラフを描く
  for(int i=0; i<100;i++){
    lg_accel[i]=accel[i];
  }
  for(int i=0; i<99;i++){
    //accelの配列を一つずらす
    accel[i]=lg_accel[i+1];
    fill(180, 59, 42);
    stroke(180, 59, 42);
    text(accel[i],100,10*i+10);
    translate(150,50);
    fill(180, 59, 42);
    stroke(180, 59, 42);
    if(i+1<99){
    line((i+1)*3,lg_accel[i+1]/100,i*3,lg_accel[i]/100);
    }
    translate(-150,-50);

  }
  //加速度
  accel[99]=pow((ax*ax+ay*ay+az*az),1.5)/1000000;
  
  //1拍の判断
  if(accel[99]-accel[90]>5000&&accel[99]>25000&&fr-p2fr>20){
    i=i+1;
    outwrite.print(",*");
    
    OscMessage myMessage1 = new OscMessage("/test1");
    myMessage1.add(i);//add message
    oscP5.send(myMessage1, myRemoteLocation1);
    
    
    
    //intervalのスムージング
    interval[0]=interval[1];
    interval[1]=interval[2];
    interval[2]=(fr-p2fr)*0.35+interval[1]*0.05;//過去2つの加速度に重みをつけて変化を滑らかにする
    
    
    //intervalが大きすぎると35にする
    if(interval[2]>35){
      interval[2]=35;
    }
    
    OscMessage myMessage2 = new OscMessage("/test2");
    myMessage2.add((int)interval[2]);//add message
    oscP5.send(myMessage2, myRemoteLocation2);
    text((int)interval[2],200,250);
    //音量のスムージング
    vel[0]=vel[1];
    vel[1]=vel[2];
    vel[2]=int(sqrt(accel[99])/2);
    
    //velが大きすぎると127にする
    if(vel[2]>127){
      vel[2]=127;
    }
    
    p2fr=fr;  //最後の1拍の時間を更新
  }
}