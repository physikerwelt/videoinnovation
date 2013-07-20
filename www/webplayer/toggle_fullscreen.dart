part of Webplayer;

typedef FullscreenCallback(bool state);

class ToggleFullscreen{
  List<FullscreenCallback> listener = new List<FullscreenCallback>();
  List<FullscreenCallback> listenerOnce = new List<FullscreenCallback>();
  bool _active = false;
  bool _browserChangeEvent = true;
  bool get inFullscreenMode => _active;
  
  final TIMEOUT = const Duration(milliseconds: 1000);
  Timer timer;
  
  call(){
    _active = !_active;
    for (int i=0; i < listener.length; i++){
      listener[i](_active);
    }
    for (int i=0; i < listenerOnce.length; i++){
      listenerOnce[i](_active);
    }
    timedRefresh();
  }
  
  ToggleFullscreen([bool startValue]){
    if (startValue != null){
      _active = startValue;
    }
    HTML.document.onFullscreenChange.listen((_)=>browserControlled());
  }
  
  void listen(FullscreenCallback f){
    listener.add(f);
  }
  
  void listenOnce(FullscreenCallback f){
    listenerOnce.add(f);
  }
  
  void browserControlled(){
    //print("browserevent");
    _browserChangeEvent = !_browserChangeEvent;
    // browser sends fullscreen change event
    if (_active && _browserChangeEvent){
      //refresh(); 
     call();
    }
  
    //if (HTML.document.fullscreenElement != null){
      // in fullscreen mode
      //call();
    //}
  }
  
  void timedRefresh(){
    if (timer != null){
      // overwrite existing timer
      timer.cancel();
    }   
    timer = new Timer(TIMEOUT, refresh);
  }
  
  void refresh(){
    for (int i=0; i < listener.length; i++){
      listener[i](_active);
    }   
  }
}