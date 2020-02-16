//CSVを保存読み込みするclass

class CSV_write_and_read {
  PrintWriter output;
  Table table;
  String[] ROOMS;
  CSV_write_and_read() {
    //filename = "temp" ;
    //output = createWriter( "temp" + ".csv");
    //保存、読み込みするファイル名
    ROOMS =new String[]{"AD2D", "AD3C", "AD3D", "AD4C", "AD16", "AD29", "AD47", "B2D5"};
  }

  //CSVの保存
  void csv_save(String data) {
    String[] d = splitTokens(data, "\t");
    //println(d[0], d[1], d[2]);
    table = loadTable("data/"+ d[0]+".csv");
    //table.addRow();
    int h = hour();
    int m = minute();
    int s = second();
    
    //100件以上データが溜まった場合0行目を消去する
    if (table.getRowCount()>99) {
      table.removeRow(0);
      for (int t=0; t<98; t++) {
        table.setString(t, 0, table.getString(t+1, 0));
        table.setString(t, 1, table.getString(t+1, 1));
        table.setString(t, 2, table.getString(t+1, 2));
      }
    }

      String t = h + ":" + nf(m, 2) + ":" + nf(s, 2);
      table.setString(table.getRowCount(), 0, t);
      table.setString(table.getRowCount()-1, 1, d[1]);
      table.setString(table.getRowCount()-1, 2, d[2]);

      saveTable(table, "data/"+ d[0]+ ".csv");
      println(data);
      //saveTable(table, d[0]+".csv");
      //String[] d = splitTokens(data, "\t");
      //output = createWriter( d[0] + ".csv");
      //println(d[1], d[2]);
      //output.flush();
    }


     //CSVをロード
    public String[] load_csv(int cnt) {
      table = loadTable("data/"+ ROOMS[cnt]+".csv");
      String[] room_data = new String[4];
      try {
        room_data[0] = ROOMS[cnt];
        room_data[1] = table.getString(table.getRowCount()-1, 0);
        room_data[2] = table.getString(table.getRowCount()-1, 1);
        room_data[3] = table.getString(table.getRowCount()-1, 2);
        //return room_data;
      }
      catch(ArrayIndexOutOfBoundsException e) {
      }
      return room_data;
    }

    //CSVをロードしテーブルを返す
    public Table get_table(int cnt) {
      table = loadTable("data/"+ ROOMS[cnt]+".csv");
      return table;
    }
    //現在開いているファイル名を返す
    public String room_name(int cnt) {
      return ROOMS[cnt];
    }
  }