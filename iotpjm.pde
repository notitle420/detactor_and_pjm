import deadpixel.keystone.*;
import gab.opencv.*;
import processing.video.*; 
import processing.opengl.*;
import org.opencv.imgproc.Imgproc;
import org.opencv.core.MatOfPoint2f;
import org.opencv.core.Point;
import org.opencv.core.Size;
import org.opencv.core.Mat;
import org.opencv.core.CvType;
import org.opencv.core.Core;
import java.util.*; 
import hypermedia.net.*;
import javax.swing.*; 
import java.util.Timer;
import java.util.TimerTask;
import processing.net.*; 
import java.security.*;
import controlP5.*;
import ddf.minim.analysis.*;
import ddf.minim.*;
import http.requests.*;

//System.load("/Users/sofutobankPC/Documents/Processing/libraries/opencv_processing/library/opencv-245.jar");

Keystone ks;  //keystoneアプリ→投射座標系ライブラリ
Capture camera;  //カメラの宣言
OpenCV opencv; //画像処理ライブラリopencv
ControlP5 cp5;  //リスト作成ライブラリ


String text;
CornerPinSurface surface; //投射表面
PGraphics offscreen; //当社表面

camera_calibration cam_calib;  //カメラ→アプリ座標
set_blur_threshold set_b_t; //２値化
get_rect_edge get_rect_edge; //四角形検出
udp_getdata get_data; //udp通信
CSV_write_and_read csv_write_read; //csv保存
http_get http_get;

String[] devices;

int w=640;  //カメラサイズ定数
int h=480;
int MODE; //MODE用変数
int Phase=0; 
int k=0;
int myCurrentIndex = 123; //カメラデバイス選択様変数

PImage camera_img = createImage(w, h, RGB); //カメラ画像
PImage camera_img_calib = createImage(w, h, RGB) ; //カメラ変換画像
PImage camera_img_threshold = createImage(w, h, RGB); //２値カメラ画像

String UDPIP = "40.78.71.118"; //UDP接続先IP
int UDPPORT = 52271; //接続先ポート
byte[] connectByte = new byte[]{ 0x0b, 1, 2, 3, 4, 5, 6, 7, 8 }; //通信用メッセージ
byte[] closeByte = new byte[] { 0x02, 1, 2, 3, 4, 5, 6, 7, 8 }; //終了用メッセージ
int udp_time_start = 1000; //udp通信開始時間
int udp_time_interval = 5000; //udp通信時間間隔
int http_time_start = 1000;
int http_time_interval = 5000;
color[] col = new color[8];

int initial_blur = 10;
int initial_threshold = 200;


void setup() {
  size(1280, 840, P3D);
  frameRate(30);
  cp5 = new ControlP5(this);
  devices = Capture.list();
  List l = Arrays.asList(Capture.list());  //カメラデバイスリストを作成


  cp5.addScrollableList("dropdown") //リストを画面に表示
    .setPosition(100, 100)
    .setSize(200, 200)
    .setBarHeight(20)
    .setItemHeight(20)
    .addItems(l);


  //カメラ→アプリ座標系　２値化　四角形検出 udp通信初期化
  cam_calib = new camera_calibration(w, h, width, height);
  set_b_t = new set_blur_threshold(initial_blur, initial_threshold, w, h, width, height);
  get_rect_edge = new get_rect_edge(w, h, width, height);
  get_data = new udp_getdata(UDPIP, UDPPORT, connectByte, closeByte, udp_time_start, udp_time_interval);
  http_get = new http_get("https://script.google.com/macros/s/AKfycbxt1Trb-Sq5kigRTLGnaRszT4yNEhCekb3ALf1DGEaDI5e2YnU/exec",http_time_start,http_time_interval);

  opencv = new OpenCV(this, w, h);

  csv_write_read = new CSV_write_and_read();

  ks = new Keystone(this);
  surface = ks.createCornerPinSurface(w, h, 20);
  offscreen = createGraphics(w, h, P3D);


  MODE = 0;
  System.loadLibrary(Core.NATIVE_LIBRARY_NAME);
}

void draw() {

  PVector surfaceMouse = surface.getTransformedMouse();

  //カメラの初期設定
  if (Phase == 0) {
    background(0);
    fill(255);
    text("please select camera device", 30, 30);
    if (myCurrentIndex != 123) {
      camera = new Capture(this, w, h, devices[myCurrentIndex]);
      camera.start();
      cp5.hide();
      Phase = 1;
    }
  }


  //カメラの初期設定が終われば開始　
  //モード0　初期モード カメラ→アプリ座標変換後が表示される。
  //モード1　カメラ→アプリ座標変換モード 変換後座標 qwas ←↑→↓ で調整  変換前をマウスクリックしながら edrfで選択
  //モード2　カメラ２値化用数値設定　←→で閾値 ↑↓でぼかし値を設定
  //モード3　アプリ座標→投射座標変換モード（２値化無し）　cで変換モード切り替えに、四隅をマウスドラッグで調整　sでその座標をセーブ　lでロード
  //モード4　アプリ座標→投射座標変換モード（２値化有り）　操作方法は同上


  if (Phase==1) {
    background(50);
    opencv.loadImage(camera);
    camera_img = opencv.getSnapshot();
    camera_img_calib = cam_calib.get(camera_img);
    camera_img_threshold=set_b_t.get(camera_img);

      switch (MODE) {
      case 0:  //initial mode
        image(camera_img_calib, 0, 0); //アプリ座標変換後を表示
        break;
      case 1:
        pushMatrix();
        translate(50, 50);
        cam_calib.desplay_rect();
        image(camera, 0, 0);
        popMatrix();
        break;
      case 2:
        image(camera_img_threshold, 0, 0);
        break;
      case 3:
        offscreen.beginDraw();
        offscreen.image(camera_img_calib, 0, 0);
        get_rect_edge.get(camera_img_threshold);
        if (ks.isCalibrating()) {
          offscreen.fill(0, 255, 0);
          offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 10, 10);
        }
        offscreen.endDraw();
        surface.render(offscreen);
        break;
      case 4:
        offscreen.beginDraw();
        offscreen.image(camera_img_threshold, 0, 0);
        get_rect_edge.get(camera_img_threshold);
        if (ks.isCalibrating()) {
          offscreen.fill(0, 255, 0);
          offscreen.ellipse(surfaceMouse.x, surfaceMouse.y, 10, 10);
        }
        offscreen.endDraw();
        surface.render(offscreen);
      default:
        break;
      }
    }
}

void keyPressed() {

  switch(key) {
  case '0':
    MODE = 0;
    break;
  case '1':
    MODE=1;
    break;
  case '2':
    MODE=2;
    break;
  case '3':
    MODE=3;
    break;
  case '4':
    MODE=4;
    break;
  }


  if (MODE==0) {
    switch(key) {
    case 'c':
    }
  }

  if (MODE==1) { //カメラ映像キャリブレーションモード
    switch(key) {
    case 'q':
      cam_calib.rect_width_increase();
      break;
    case 'a':
      cam_calib.rect_width_decrease();
      break;
    case 'w':
      cam_calib.rect_height_increase();
      break;
    case 's':
      cam_calib.rect_height_decrease();
      break;
    case 'e':
      if (mousePressed) { 
        cam_calib.set_left_top(mouseX-50, mouseY-50);
      }
      break;
    case 'r':
      if (mousePressed) { 
        cam_calib.set_right_top(mouseX-50, mouseY-50);
      }
      break;
    case 'd':
      if (mousePressed) { 
        cam_calib.set_left_bottom(mouseX-50, mouseY-50);
      }
      break;
    case 'f':
      if (mousePressed) { 
        cam_calib.set_right_bottom(mouseX-50, mouseY-50);
      }
      break;
    }
    if (key == CODED) {
      switch(keyCode) {
      case UP:
        cam_calib.rect_up();
        break;
      case DOWN:
        cam_calib.rect_down();
        break;
      case LEFT:
        cam_calib.rect_left();
        break;
      case RIGHT:
        cam_calib.rect_right();
        break;
      }
    }
  }

  if (MODE==2||MODE==4) {
    if (key == CODED) {
      switch(keyCode) {
      case UP:
        set_b_t.blur_up();
        break;
      case DOWN:
        set_b_t.blur_down();
        break;
      case LEFT:
        set_b_t.threshold_down();
        break;
      case RIGHT:
        set_b_t.threshold_up();
        break;
      }
    }
  }

  if (MODE==3 || MODE==4) {
    switch(key) {
    case 'c':
      // enter/leave calibration mode, where surfaces can be warped 
      // and moved
      ks.toggleCalibration();
      break;

    case 'l':
      // loads the saved layout
      ks.load();
      break;

    case 's':
      // saves the layout
      ks.save();
      break;
    }
  }
}

void dropdown(int n) {
  println(n);  
  myCurrentIndex = n;
}

void captureEvent(Capture c) {
  c.read();
}
