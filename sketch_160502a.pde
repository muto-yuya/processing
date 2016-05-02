//加速度センサのポート
import processing.serial.*;
Serial myPort;
//音量出力用のポート
import rwmidi.*;
MidiOutput output;

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

//;                  //Velocity（音の強さ）の設定0〜127　音の強さ
int program =int(random(1,10)); //プログラムチェンジ（音色）の設定音色
int dev = 1;                    //音源の設定
int devLength = 0;              //デバイスの数
int count=0;                    //現在の音符の位置
int i=0;                        //最初から今までトータルの拍数     
int fr=0;                       //最初から今までの経過時間(単位はframeRate)
int pfr=0;                      //最後の音符が鳴ってからの経過時間(単位はframeRate)
int p2fr=0;                     //最後の拍からの経過時間(単位はframeRate)
float[] interval={20,20,20};
int[] vel={100,100,100};

//楽譜(カエルの歌)
int[] ch0={60,62,64,65,64,62,60,0,
           64,65,67,69,67,65,64,0,
           60,0,60,0,60,0,60,0,
           60,62,64,65,64,62,60,0
           };
           
int[] ch1={55,0,55,0,55,0,55,0,
           55,0,55,0,55,0,55,0,
           55,0,55,0,55,0,55,0,
           55,0,55,0,55,0,55,0,
           };
           
int[] ch2={52,0,52,0,52,0,52,0,
           52,0,52,0,52,0,52,0,
           52,0,52,0,52,0,52,0,
           52,0,52,0,52,0,52,0,
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
}
 
void draw () {
  background(210, 231, 200);
  /*background (0, 104, 55);
  text ("Device Name: " + output.getName (), 15, 20);
  text ("Program Change: " + program, 15, 40);
  text ("Click and release MLB! ", 15, 80);
  text (count,15,100);
  text(vel,15,120);
  text(fr/120,15,135);
  text(i,15,150);
  text(fr-pfr,15,165);
  text(interval,300,150);
  */
  text(i,300,300);
  text(interval[2],300,320);
  text(vel[2],300,340);
  readData();
  ensou();
  fr++;   //経過時間の更新
}

//音符を鳴らす
void ensou(){
  while(count<i){  //音符間の時間が(=fr-pfr)interval[2] 1拍で音符2つ分鳴らすのでcount/2<i

    if(count<ch0.length){  //countが楽譜の範囲にあるとき(out of range を防ぐ)
      if(count==0){
        output.sendNoteOn(0,ch0[count],vel[2]);
        output.sendNoteOn(1,ch1[count],vel[2]);
        output.sendNoteOn(2,ch2[count],vel[2]);
       
        }else{
          //0以外の場合は前回の音を消し、今回の音を鳴らす
          if(ch0[count]!=0){
            output.sendNoteOff(0,ch0[count-1],vel[2]);
            output.sendNoteOn(0,ch0[count],vel[2]);
        }
        if(ch1[count]!=0){
            output.sendNoteOff(1,ch1[count-1],vel[2]);
            output.sendNoteOn(1,ch1[count],vel[2]);
        }
        if(ch2[count]!=0){
            output.sendNoteOff(2,ch2[count-1],vel[2]);
            output.sendNoteOn(2,ch2[count],vel[2]);
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
  interval[2]=(fr-p2fr)*0.50;
  if(interval[2]>35){
    interval[2]=35;
  }
  p2fr=fr;
  }
}

void readData() {
  //arduinoからの加速度読み込み
  String s="";
  while (myPort.available()>0) {
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
  
  //外部ファイルへの出力内容(csv形式)
  outwrite.print(fr);
  outwrite.print(",");
  outwrite.print(accel[99]);
  outwrite.print(",");
  outwrite.print(accel[98]-accel[95]);
  outwrite.print(",");
  outwrite.print(accel[98]-accel[90]);
  outwrite.print(",");
  outwrite.print(fr-p2fr);


  //1拍の判断
  if(accel[99]-accel[80]>7000&&accel[99]>40000&&fr-p2fr>25){
    i=i+1;
    outwrite.print(",*");
    
    //intervalのスムージング
    interval[0]=interval[1];
    interval[1]=interval[2];
    interval[2]=sqrt(((fr-p2fr)+(interval[0]+interval[1])))+11;//急激な変化は不自然なので過去3つの平方根に10を足す
    
    
    //intervalが大きすぎると35にする
    if(interval[2]>35){
      interval[2]=35;
    }
    
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
  outwrite.println("");
}