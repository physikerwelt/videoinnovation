part of Webplayer;

// enable pseudo streaming: http://www.longtailvideo.com/support/jw-player/28855/pseudo-streaming-in-flash/

// jwplayer version 6

class PlayerWrapper {
  double ratio = 0.0;
  int width;
  int height;
  HTML.DivElement divwrapper;
  
  List<Function> playingListener = new List<Function>();
  List<Function> seekListener = new List<Function>();
  List<Function> pauseListener = new List<Function>();
  List<Function> playListener = new List<Function>();
  
  PlayerWrapper(){
   var player =  JS.context.jwplayer();
   player.onTime(new JS.Callback.many((o)=>playingCallback(o.position)));
   player.onSeek(new JS.Callback.many((o)=>seekCallback(o.offset)));
   player.onPause(new JS.Callback.many((o)=>pauseCallback()));
   player.onPlay(new JS.Callback.many((o)=>playCallback()));
   var h = JS.context.playerHeight;
   var w = JS.context.playerWidth;
   ratio = w/h;
   width = w.toInt();
   height = h.toInt();
   divwrapper = HTML.query('#player');
  }
  
  void togglePseudoFullScreen(bool fullscreen){
    if (fullscreen){
      // enter fullscreen
      num h = divwrapper.offsetHeight;
      num w = divwrapper.offsetWidth;
      num tRatio = w/h;
      if (tRatio > ratio){
        resize_h(h);
      } else {
        resize_w(w);
      }
    } else {
      resize_wh(width, height);
    }
  }
  
  void addListenerPlaying(Function f){
    playingListener.add(f);
  }
  
  void addListenerSeek(Function f){
    seekListener.add(f);
  }
  
  void addListenerPlay(Function f){
    playListener.add(f);
  }
  
  void addListenerPause(Function f){
    pauseListener.add(f);
  }
  
  void playingCallback(double position){
    int timestamp = position.toInt();
    for (int i=0; i < playingListener.length; i++){
      playingListener[i](timestamp);
    }
  }
  
  void seekCallback(int timestamp){
    for (int i=0; i < seekListener.length; i++){
      seekListener[i](timestamp);
    }
  }
  
  void playCallback(){
    for (int i=0; i < playListener.length; i++){
      playListener[i]();
    }
  }
  
  void pauseCallback(){
    for (int i=0; i < pauseListener.length; i++){
      pauseListener[i]();
    }
  }
  
  void jumpTo(int timestamp){
    JS.context.jwplayer().seek(timestamp);
  }
  
  void resize_w(int width){
    var player =  JS.context.jwplayer();
    double height = width.toDouble()/ratio;
    player.resize(width, height);
  }
  
  void resize_h(int height){
    var player =  JS.context.jwplayer();
    double width = height.toDouble()*ratio;
    player.resize(width, height);
  }
  
  void resize_wh(int width, int height){
    var player =  JS.context.jwplayer();
    double height = width.toDouble()/ratio;
    player.resize(width, height);
  }
  
  int getTimestamp(){
    var player =  JS.context.jwplayer();
    double timestamp = player.getPosition();
    if (timestamp != null){
      int t = timestamp.floor();
      return t;    
    } else {
      return 0;
    }
  }
  
  void pause(){
    var player = JS.context.jwplayer();
    player.pause();
  }
  
  void play(){
    var player = JS.context.jwplayer();
    player.play();
  }
  
}