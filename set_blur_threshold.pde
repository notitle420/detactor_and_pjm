//２値化用クラス

class set_blur_threshold extends PApplet {
  private OpenCV opencv;
  int blur_value;
  int threshold_value;
  int camera_w;
  int camera_h;


  set_blur_threshold(int blur, int threshold, int cam_w, int cam_h, int w, int h) {
    camera_w = cam_w;
    camera_h = cam_h;
    width = w;
    height = h;
    opencv = new OpenCV(this, cam_w, cam_h);
    blur_value=blur;
    threshold_value=threshold;
  }

  public PImage get(PImage img) {
    opencv.loadImage(img);
    opencv.gray(); //グレースケール化
    opencv.blur(blur_value); //ぼかし
    opencv.threshold(threshold_value); //２値化
    return opencv.getOutput();
  }

  void blur_down() {
    if (blur_value > 1) {
      blur_value = blur_value-1;
      println(blur_value);
    }  //blur_down
  }

  void blur_up() {
    if (blur_value < 100) {
      blur_value = blur_value+1;
      println(blur_value);
    } //blur_up
  }

  void threshold_down() {
    if (threshold_value > 1) {
      threshold_value = threshold_value-1;
      println(threshold_value);
    }  //threshold_value_down
  }

  void threshold_up() {
    if (threshold_value < 252) {
      threshold_value = threshold_value+1;
      println(threshold_value);
    }  //threshold_value_up
  }
  
  
}