class get_rect_edge extends PApplet {

  OpenCV opencv;
  int camera_w;
  int camera_h;
  int[][] temp;
  ArrayList<Contour> contours;
  ArrayList<Contour> polygons;
  int flag_for_inital_contour_area;
  float initial_contour_area;
  float ApproximationFactor;
  float weight_for_big_rect;
  float get_rect_area;

  get_rect_edge(int cam_w, int cam_h, int w, int h) {
    camera_w = cam_w;
    camera_h = cam_h;
    width = w;
    height = h;
    opencv = new OpenCV(this, camera_w, camera_h);
    temp = new int[4][2]; //コーナー座標入れ替えよう変数
    flag_for_inital_contour_area = 0 ; //初期取得四角形面積用フラグ
    initial_contour_area=3000; //初期取得四角形面積
    ApproximationFactor=10; //四角形の検出しやすさ
    weight_for_big_rect = 2.5; //初期値から何倍の大きさで描画を変化させるか
    get_rect_area = 3000;
  }

  //四角形検出用関数
  void get(PImage camera) {
    opencv.loadImage(camera);
    contours = opencv.findContours();//エッジを検出
    int rect_num=0;
    for (Contour contour : contours) {
      contour.setPolygonApproximationFactor(ApproximationFactor); //四角形の見做しやすさを設定 0が厳しく　100がゆるい
      //検出したエッジをポリゴン化し、四角形を取得
      if (contour.getPolygonApproximation().getPoints().size() == 4 && contour.area() >= get_rect_area) {//四角形で面積が5000以上のものを認識
        int i=0;
        //最初に検出した四角形の大きさを初期値とする
        if (flag_for_inital_contour_area==0 && contour.area() < 3000000) {
          initial_contour_area = contour.area();
          println("initial=" + initial_contour_area);
          //initial_contour_area = initial_contour_area * weight_for_big_rect; //初期値に重みをかける
          println("initial *2.5 = " + initial_contour_area*2.5);
          flag_for_inital_contour_area = 1;
        }

        for (PVector point : contour.getPolygonApproximation().getPoints()) { //検出している四角形を描画
          temp[i][0] = (int)point.x;
          temp[i][1] = (int)point.y; //四角形の頂点を取得
          i++;
        }


        //println(temp[0][0],temp[0][1],temp[1][0],temp[1][1],temp[2][0],temp[2][1],temp[3][0],temp[3][1]);
        Comp comp = new Comp ();
        comp.set_index (0);  //2次元目のインデックス0番でソート
        Arrays.sort (temp, comp); //xでソート
        temp = compare2(temp); //左上0左下１右下２左上３
        //draw_get_rect_edge(rect_num,temp); //四角形を描画

        try {

          PVector center = new PVector();
          //四角形の中心を計算
          center.x = (temp[0][0]+temp[1][0]+temp[2][0]+temp[3][0])/4;
          center.y = (temp[0][1]+temp[1][1]+temp[2][1]+temp[3][1])/4;
          //四角形の傾きを計算
          float contour_angle = tan(float((temp[3][1]-temp[0][1]))/float((temp[3][0]-temp[0][0]))); //四角形の角度
          //四角形の中天の距離
          float distancex = (dist(temp[0][0], temp[0][1], temp[3][0], temp[3][1])+dist(temp[1][0], temp[1][1], temp[2][0], temp[2][1]))/2;
          float distancey = (dist(temp[1][0], temp[1][1], temp[0][0], temp[0][1])+dist(temp[2][0], temp[2][1], temp[3][0], temp[3][1]))/2;
          //距離を丸め込み
          int tempdistancex = (int)distancex/10;
          int tempdistancey = (int)distancey/10;
          //float now_area = (float)contour.area();
          //println("initial =" + initial_contour_area);
          //println("now =" + contour.area());
          println(tempdistancex,tempdistancey);
          //初期値の2.5倍大きく正方形ならば
          if (contour.area() > initial_contour_area * 2.5 && (tempdistancey-5 <= tempdistancex && tempdistancex <= tempdistancey+5))
          {
            draw_graph(center, contour_angle, temp); //グラフを表示
          } 
          //メーターを表示 縦横比で長方形を検出
          else if (contour.area() > initial_contour_area*1.2 && ((tempdistancey-5 > tempdistancex) || (tempdistancex-5> tempdistancey)) ) {
            int vert_horiz=0;
            if (tempdistancey<=tempdistancex) {
              vert_horiz=0;
            } else if (tempdistancex<tempdistancey) {
              vert_horiz=1;
            }
            println(tempdistancex,tempdistancey);
            draw_meter(rect_num, contour_angle, center, temp, vert_horiz);
          } else {
            draw_data(rect_num,temp, center, contour_angle); //それ以外ならudpデータを表示
          }

          //draw_area(contour.area(), center, contour_angle);

          rect_num++;
        }
        catch( AssertionError e )
        {
          e.printStackTrace();
        }
      }
    }
  }


  class Comp implements Comparator {

    int index = 0;

    public void set_index (int i) {
      index = i;
    }

    public int compare (Object a, Object b) {
      int[] float_a = (int[]) a;
      int[] float_b = (int[]) b;
      return (float_a[index] - float_b[index]);
    }
  }

  public int[][] compare2(int[][] temp) {
    if (temp[0][1]>temp[1][1]) { //左側をyでソート
      int tmp = temp[0][1];
      temp[0][1] = temp[1][1];
      temp[1][1] = tmp;

      tmp = temp[0][0];
      temp[0][0] = temp[1][0];
      temp[1][0] = tmp;
    }
    if (temp[2][1]<temp[3][1]) { //右側をyでソート
      int tmp = temp[2][1];
      temp[2][1] = temp[3][1];
      temp[3][1] = tmp;

      tmp = temp[2][0];
      temp[2][0] = temp[3][0];
      temp[3][0] = tmp;
    }
    return(temp);
  }
}