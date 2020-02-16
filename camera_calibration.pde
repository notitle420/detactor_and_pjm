//カメラ→アプリ座標変換クラス //<>//

class camera_calibration extends PApplet { //

  private PVector after_left_top, after_left_bottom, after_right_top, after_right_bottom;
  public ArrayList<PVector> after_corner;
  public PVector input_left_top, input_left_bottom, input_right_top, input_right_bottom;
  private ArrayList<PVector> input_corner;
  int camera_w;
  int camera_h;
  private OpenCV opencv;

  camera_calibration(int cam_w, int cam_h, int w, int h) {
    camera_w = cam_w;
    camera_h = cam_h;
    width = w;
    height = h;
    after_left_top=new PVector(0, 0); 
    after_left_bottom=new PVector(0, camera_h);
    after_right_top=new PVector(camera_w, 0);
    after_right_bottom=new PVector(camera_w, camera_h);
    after_corner = new ArrayList<PVector>();
    Collections.addAll(after_corner, after_left_top, after_left_bottom, after_right_bottom, after_right_top);

    input_left_top=new PVector(0, 0); 
    input_left_bottom=new PVector(0, camera_h);
    input_right_top=new PVector(camera_w, 0);
    input_right_bottom=new PVector(camera_w, camera_h);
    input_corner = new ArrayList<PVector>();
    Collections.addAll(input_corner, input_left_top, input_left_bottom, input_right_bottom, input_right_top);
    
    camera_img = createImage(w,h,RGB);

    opencv = new OpenCV(this, cam_w, cam_h);
  }
  
  
  //変換後座標の四角形を表示
  public void desplay_rect() {
    draw_rect(after_corner, input_corner);
  }
  //変換後座標の四角形を設定
  public void rect_width_increase() {
    if ( after_left_top.x > 0 && after_right_top.x < camera_w) {
      after_left_top.add(-10, 0); 
      after_left_bottom.add(-10, 0);
      after_right_top.add(10, 0);
      after_right_bottom.add(10, 0);
    }
  }

  public void rect_width_decrease() {
    if ( after_right_top.x - after_left_top.x > 10 ) {
      after_left_top.add(10, 0); 
      after_left_bottom.add(10, 0);
      after_right_top.add(-10, 0);
      after_right_bottom.add(-10, 0);
    }
  }

  public void rect_height_increase() {
    if ( after_left_top.y > 0 && after_left_bottom.y < camera_h) {
      after_left_top.add(0, -10); 
      after_left_bottom.add(0, 10);
      after_right_top.add(0, -10);
      after_right_bottom.add(0, 10);
    }
  }

  public void rect_height_decrease() {
    if ( after_left_bottom.y - after_left_top.y >10 ) {
      after_left_top.add(0, 10); 
      after_left_bottom.add(0, -10);
      after_right_top.add(0, 10);
      after_right_bottom.add(0, -10);
    }
  }

  public void rect_left() {
    if ( after_left_top.x > 0 ) {
      after_left_top.add(-10, 0); 
      after_left_bottom.add(-10, 0);
      after_right_top.add(-10, 0);
      after_right_bottom.add(-10, 0);
    }
  }

  public void rect_right() {
    if ( after_right_top.x < camera_w ) {
      after_left_top.add(10, 0); 
      after_left_bottom.add(10, 0);
      after_right_top.add(10, 0);
      after_right_bottom.add(10, 0);
    }
  }

  public void rect_up() {
    if ( after_left_top.y > 10 ) {
      after_left_top.add(0, -10); 
      after_left_bottom.add(0, -10);
      after_right_top.add(0, -10);
      after_right_bottom.add(0, -10);
    }
  }

  public void rect_down() {
    if ( after_left_bottom.y < camera_h ) {
      after_left_top.add(0, 10); 
      after_left_bottom.add(0, 10);
      after_right_top.add(0, 10);
      after_right_bottom.add(0, 10);
    }
  }
  //変換後座標と変換前座標変換行列を計算
  public Mat getPerspectiveTransformation(ArrayList<PVector> afterPoints, ArrayList<PVector> inputPoints) {
    Point[] points = new Point[4];
    for (int i = 0; i < 4; i++) {
      points[i] = new Point(afterPoints.get(i).x, afterPoints.get(i).y);
    }

    MatOfPoint2f after_marker = new MatOfPoint2f();
    after_marker.fromArray(points);  //変換先の座標をマーカーとする

    for (int i = 0; i < 4; i++) {
      points[i] = new Point(inputPoints.get(i).x, inputPoints.get(i).y);
    }
    MatOfPoint2f input_marker = new MatOfPoint2f(points);//変換前の座標をマーカーにする
    return Imgproc.getPerspectiveTransform(input_marker, after_marker);
  }

  //変換前座標の取得
  public void set_left_top(int x, int y) {
    input_left_top.set(x, y);
  }
  public void set_left_bottom(int x, int y) {
    input_left_bottom.set(x, y);
  }
  public void set_right_bottom(int x, int y) {
    input_right_bottom.set(x, y);
  }
  public void set_right_top(int x, int y) {
    input_right_top.set(x, y);
  }

  //変換開始
  public Mat warpPerspective(ArrayList<PVector> inputPoints, ArrayList<PVector> afterPoints) {
    Mat transform = getPerspectiveTransformation(inputPoints, afterPoints);
    Mat unWarpedMarker = new Mat(camera_w, camera_h, CvType.CV_8UC1);    
    Imgproc.warpPerspective(opencv.getColor(), unWarpedMarker, transform, new Size(w, h));
    return unWarpedMarker;
  }

  //出力
  public PImage get(PImage img) {
    opencv.loadImage(img);
    opencv.toPImage(warpPerspective(input_corner, after_corner), img);
    return img;
  }
}
