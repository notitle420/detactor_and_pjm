
//描画用クラス

//カメラ→アプリの変換前座標と変換後座標のコーナーを表示
public void draw_rect(ArrayList<PVector> afterPoints, ArrayList<PVector> inputPoints) {
  noFill();
  stroke(255, 0, 0);
  beginShape();
  for (int i = 0; i < 4; i++) {
    vertex(afterPoints.get(i).x, afterPoints.get(i).y);
  };
  endShape(CLOSE);

  //beginShape();
  //for (int i = 0; i < 4; i++) {
  //  vertex(afterPoints.get(i).x, afterPoints.get(i).y);
  //};
  //endShape(CLOSE);

  for (int i = 0; i < 4; i++) {
    ellipse(inputPoints.get(i).x, inputPoints.get(i).y, 10, 10);
  };



  text("TOP LEFT", inputPoints.get(0).x, inputPoints.get(0).y);
  text("BOTTOM LEFT", inputPoints.get(1).x, inputPoints.get(1).y);
  text("TOP RIGHT", inputPoints.get(3).x, inputPoints.get(3).y);
  text("BOTTOM RIGHT", inputPoints.get(2).x, inputPoints.get(2).y);
}

//検出した四角形の描画
//public void draw_get_rect_edge(int rect_num, int [][] p) {
//  offscreen.beginDraw();
//  offscreen.noFill();
//  offscreen.strokeWeight(3);
//  offscreen.stroke(0, 0, 0);
//  switch(rect_num) {
//  case 0:
//    offscreen.stroke(255, 0, 0);
//    break;
//  case 1:
//    offscreen.stroke(0, 255, 0);
//    break;
//  case 2:
//    offscreen.stroke(0, 0, 255);
//  case 3:
//    offscreen.stroke(255, 255, 0);
//    break;
//  }
//  offscreen.beginShape();
//  for (int i=0; i<4; i++) {
//    offscreen.vertex(p[i][0], p[i][1]);
//  }
//  offscreen.endShape(CLOSE);
//  offscreen.endDraw();
//}

//UDP通信によって得たデータをマッピング
public void draw_data(int counter, int [][] p, PVector center, float angle) {

  offscreen.beginDraw();
  offscreen.noFill();
  offscreen.strokeWeight(3);
  offscreen.stroke(0, 0, 0);
  switch(counter) {
  case 0:
    offscreen.stroke(255, 0, 0);
    break;
  case 1:
    offscreen.stroke(0, 255, 0);
    break;
  case 2:
    offscreen.stroke(0, 0, 255);
  case 3:
    offscreen.stroke(255, 255, 0);
    break;
  }
  offscreen.beginShape();
  for (int i=0; i<4; i++) {
    offscreen.vertex(p[i][0], p[i][1]);
  }
  offscreen.endShape(CLOSE);
  offscreen.endDraw();

  offscreen.beginDraw();
  offscreen.pushMatrix();
  offscreen.fill(0);
  offscreen.textSize(16);
  offscreen.textAlign(CENTER);
  offscreen.translate(center.x, center.y);
  offscreen.rotate(angle);
  //String text = "x:"+center.x + "\n" + "y:"+center.y;

  String[] data = csv_write_read.load_csv(1);
  String text="over 3";

  if (data!=null) {

    if (counter == 0) {
      int h = hour();
      int m = minute();
      int s = second();
      String t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
      text = "Time" + "\n" + t;
    }

    if (counter == 1) {
      text = "Place" + "\n" + data[0];
    }
    if (counter == 2) {
      text = "Temp." + "\n" + data[2];
    } else if (counter == 3) {
      text = "Hum." + "\n" + data[3];
    } 

    offscreen.text(text, 0, 0);
  }
  offscreen.popMatrix();
  offscreen.endDraw();
}

//グラフ描画
public void draw_graph(PVector center, float angle, int[][] cp) {
  //offscreen.beginDraw();
  //offscreen.pushMatrix();
  //offscreen.fill(0);
  //offscreen.textSize(32);
  //offscreen.textAlign(CENTER);
  //offscreen.translate(center.x, center.y);
  //offscreen.rotate(angle);
  ////String text = "x:"+center.x + "\n" + "y:"+center.y;
  //String gtext = "graph";
  //offscreen.text(gtext, 0, 0);
  //offscreen.popMatrix();
  //offscreen.endDraw();

  offscreen.beginDraw();
  int timecnt = 0;
  Table table = csv_write_read.get_table(1);
  String roomname = csv_write_read.room_name(1);
  //float distancex = (dist(cp[0][0], cp[0][1], cp[2][0], cp[2][1])+dist(cp[1][0], cp[1][1], cp[3][0], cp[3][1]))/2;
  //float distancey = (dist(cp[0][0], cp[0][1], cp[1][0], cp[1][1])+dist(cp[2][0], cp[2][1], cp[3][0], cp[3][1]))/2;
  float rect_width_max = (cp[3][0]+cp[2][0])/2;
  float rect_width_min = (cp[0][0]+cp[1][0])/2;
  float rect_height_max = (cp[0][1]+cp[3][1])/2;
  float rect_height_min = (cp[1][1]+cp[2][1])/2;
  offscreen.pushMatrix();
  offscreen.translate(center.x, center.y);
  offscreen.rotate(angle);
  offscreen.noStroke();
  //データを四角形内にマッピング
  for (int i=0; i<table.getRowCount(); i++) {
    float tx = map(timecnt, 0, 100, rect_width_min, rect_width_max );
    float ty1 = map(table.getFloat(i, 1), 20, 35, rect_height_min, rect_height_max);
    float ty2 = map(table.getFloat(i, 2), 30, 60, rect_height_min, rect_height_max);
    offscreen.fill(255, 0, 0);
    offscreen.ellipse(tx-center.x+10, ty1-center.y, 4, 4);
    offscreen.fill(0, 255, 0);
    offscreen.ellipse(tx-center.x+10, ty2-center.y, 4, 4);
    timecnt++;
  }
  offscreen.fill(0);
  offscreen.translate(-(rect_width_max-rect_width_min)/2, -(rect_height_min-rect_height_max)/2);
  offscreen.text(roomname, 20, 20);
  offscreen.translate(0, rect_height_min-rect_height_max);
  offscreen.text("start" + table.getString(0, 0), 50, -20);
  offscreen.text("end" + table.getString(table.getRowCount()-1, 0), 50, 0);
  offscreen.popMatrix();
  offscreen.endDraw();
}

//メーターを描画
public void draw_meter(int rect_num, float contour_angle, PVector center, int[][] cp, int verthoriz) {

  col[0] = color(255, 127, 31);
  col[1] = color(31, 255, 127);
  col[2] = color(127, 31, 255);
  col[3] = color(31, 127, 255);
  col[4] = color(127, 255, 31);
  col[5] = color(127);
  col[6] = color(255, 127, 31);
  col[7] = color(31, 255, 127);

  offscreen.beginDraw();
  PVector meter1up = new PVector();
  PVector meter1down = new PVector();
  int cnt = 1;
  String[] data = csv_write_read.load_csv(cnt);
  String dataset=data[2];
  int min=0;
  int max=50;
  String textdata="temp:";




  if (rect_num==0) {
    dataset=data[2];
    min=0;
    max=40;
    textdata="temp:";
  } else if (rect_num==1) {
    dataset=data[3];
    min=30;
    max=60;
    textdata="hum:";
  }


  if (verthoriz==0) {
    meter1up.x= float(dataset);
    meter1down.x = float(dataset);
    meter1up.x = map(meter1up.x, min, max, cp[0][0], cp[3][0]);
    meter1up.y = float((cp[3][1]-cp[0][1]))/float((cp[3][0]-cp[0][0]))*((meter1up.x-float(cp[0][0])))+cp[0][1];
    meter1down.x = map(meter1down.x, min, max, cp[1][0], cp[2][0]);
    meter1down.y = float((cp[2][1]-cp[1][1]))/float((cp[2][0]-cp[1][0]))*(meter1down.x-float(cp[1][0]))+cp[1][1];
    println(cp[0][0], cp[0][1],cp[1][0], cp[1][1],meter1down.x, meter1down.y, meter1up.x, meter1up.y);
    offscreen.fill(col[cnt]);
    offscreen.noStroke();
    offscreen.beginShape();
    offscreen.vertex(cp[0][0], cp[0][1]);
    offscreen.vertex(cp[1][0], cp[1][1]);
    offscreen.vertex(meter1down.x, meter1down.y);
    offscreen.vertex(meter1up.x, meter1up.y);
    offscreen.endShape(CLOSE);
    offscreen.fill(255);
    offscreen.pushMatrix();
    offscreen.translate(center.x, center.y);
    offscreen.rotate(contour_angle);
    offscreen.textSize(16);
    offscreen.textAlign(CENTER);
    offscreen.fill(255);
    offscreen.text(data[0] + textdata + dataset, 0, 0);
    offscreen.popMatrix();
  }

  if (verthoriz==1) {
    meter1up.x= float(dataset);
    meter1down.x = float(dataset);
    meter1up.x = map(meter1up.x, min,max, cp[1][0], cp[0][0]);
    meter1up.y = float((cp[1][1]-cp[0][1]))/float((cp[1][0]-cp[0][0]))*((meter1up.x-float(cp[0][0])))+cp[0][1];
    meter1down.x = map(meter1down.x, min, max, cp[2][0], cp[3][0]);
    meter1down.y = float((cp[2][1]-cp[3][1]))/float((cp[2][0]-cp[3][0]))*(meter1down.x-float(cp[3][0]))+cp[3][1];
    //println(cp[0][0], cp[0][1],cp[1][0], cp[1][1],meter1down.x, meter1down.y, meter1up.x, meter1up.y);
    offscreen.fill(col[cnt]);
    offscreen.noStroke();
    offscreen.beginShape();
    offscreen.vertex(meter1up.x, meter1up.y);
    offscreen.vertex(cp[1][0], cp[1][1]);
    offscreen.vertex(cp[2][0], cp[2][1]);
    offscreen.vertex(meter1down.x, meter1down.y);
    offscreen.endShape(CLOSE);

    offscreen.pushMatrix();
    offscreen.translate(center.x, center.y);
    offscreen.rotate(contour_angle);
    offscreen.fill(255);
    offscreen.textSize(16);
    offscreen.textAlign(CENTER);
    offscreen.text(data[0] + "\n" + textdata + "\n" + dataset, 0, 0);
    offscreen.popMatrix();
  }
  offscreen.endDraw();
}
//検出四角形面積表示用
public void draw_area(float s, PVector center, float angle) {
  offscreen.beginDraw();
  offscreen.pushMatrix();
  offscreen.fill(0);
  offscreen.textSize(16);
  offscreen.textAlign(CENTER);
  offscreen.translate(center.x, center.y);
  offscreen.rotate(angle);
  offscreen.text(nf(s), 0, 0);
  offscreen.popMatrix();
  offscreen.endDraw();
}
