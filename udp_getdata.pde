public class udp_getdata {
  UDP udp;
  Timer timer;
  TimeStar star;
  int baseTime;
  String lastMessage;
  String connectip;
  int port;
  byte[] message;
  byte[] closemessage;

  udp_getdata(String ip, int pt, byte[] sendmsg, byte[] closemsg, int start_time, int time_intval) {
    udp = new UDP(this) ;
    udp.listen( true );
    timer = new Timer(); //タイマーインスタンス作成
    star = new TimeStar(); //タイマータスクインスタンス作成
    println( "connected" );
    lastMessage = "AD47" + "\t" + "26.8" +"\t" + "56.9";
    timer.schedule(star, start_time, time_intval); //通信間隔の設定 起動からms後にms間隔で
    connectip=ip;
    port = pt;
    message = sendmsg;
    closemessage = closemsg;
  }


  void SendData() {
    baseTime = millis();
    //byte[]  message = new byte[] { 0x0b, 1, 2, 3, 4, 5, 6, 7, 8 } ;
    //dp.send(message, "40.78.71.118", 52271 );
    udp.send(message, connectip, port );
    //lastMessage = "AD4D  26.8  56.9";
  }

  int recCount = 0 ;

  void receive( byte[] data) {
    recCount ++ ;
    //print( "receive (" + recCount + "): " );

    int len = data.length - 32 ;
    byte[] message = new byte[ len ] ; 
    System.arraycopy(data, 32, message, 0, len);

    String msg = new String( message );
    lastMessage = msg ; //from "+ip+" on port "+port ;
    //println( lastMessage );
    //message = new byte[] { 0x02, 1, 2, 3, 4, 5, 6, 7, 8 } ;
    //println( lastMessage );
    csv_write_read.csv_save(lastMessage);
  }



  public String[] return_data() {
    String[] s = splitTokens(lastMessage, "\n");
    String[] d = splitTokens(s[0], "\t");
    return d;
  }

  class TimeStar extends TimerTask {
    public void run() {
      udp.send(closemessage, connectip, port );
      SendData();
      println("conection....");
    }
  }
}