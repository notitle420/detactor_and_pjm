public class http_get {
  String URL;
  Timer timer;
  TimeStar star;
  JSONObject result;
  GetRequest get;


  http_get(String url, int start_time, int time_intval) {
    String URL = url;
    timer = new Timer(); //タイマーインスタンス作成
    star = new TimeStar(); //タイマータスクインスタンス作成
    timer.schedule(star, start_time, time_intval);
    get = new GetRequest(URL);
  }
  
  class TimeStar extends TimerTask {
    public void run() {
      get.send();
      JSONObject result = parseJSONObject(get.getContent());
      println("conection....");
      println(result);
    }
  }
  
}
