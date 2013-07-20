
part of Webplayer;

class Transcription {
  
  List<Sentence> sentences = new List<Sentence>();
  HTML.DivElement bottom = HTML.query('#playerBottom');
  HTML.ParagraphElement last = HTML.query('#t_last');
  HTML.ParagraphElement current = HTML.query('#t_current');
  HTML.ParagraphElement next = HTML.query('#t_next');
  HTML.SpanElement button = HTML.query('#resizeTranscription');
  HTML.DivElement left = HTML.query('#left');
  HTML.DivElement player = HTML.query('#player');
  
  bool open = true;
  
  Transcription.fromJson(List json){
    for (int i=0; i < json.length; i++){
      sentences.add(new Sentence(json[i]['content'], json[i]['begin'], json[i]['end']));
    }
    button.onClick.listen(toggle);
  }
  
  void update(int timestamp){
    if (open){
      int i = sentences.length;
      while(i-- > 0){
        if (sentences[i].begin <= timestamp){
          return setActiveSentence(i);
        }
      }
    }
  }
  
  setActiveSentence(int currentIndex) {
    int l = currentIndex-1;
    int n = currentIndex+1;
    if (l < 0){
      last.innerHtml = '';
    } else {
      last.innerHtml = sentences[l].content;
    }    
    current.innerHtml = sentences[currentIndex].content;
    if (n < sentences.length){
      next.innerHtml = sentences[n].content;
    } else {
      next.innerHtml = '';
    } 
  }
  
  void toggle(HTML.MouseEvent e, [bool open]){
    if (open == null){
      open = this.open;
      this.open = !open;
    }
    if (open){
      // close transcription
      last.classes.add('opacity30');
      current.classes.add('opacity30');
      next.classes.add('opacity30');
      button.innerHtml = localization.open_transcription;
      
      player.classes.remove('pY');
      left.classes.remove('pY');
      bottom.classes.remove('playerBottomExp');
      
      if (toggleFullscreen.inFullscreenMode){
        // fullscreen is active
        bottom.classes.add('playerBottomCollapsed_fullscreen');
        player.classes.add('pY_fullscreen_collapsed');
        left.classes.add('pY_fullscreen_collapsed');
        bottom.classes.remove('playerBottomCollapsed');
        player.classes.remove('pY_collapsed');
        left.classes.remove('pY_collapsed');
      } else {
        bottom.classes.add('playerBottomCollapsed');
        player.classes.add('pY_collapsed');
        left.classes.add('pY_collapsed');
        bottom.classes.remove('playerBottomCollapsed_fullscreen');
        player.classes.remove('pY_fullscreen_collapsed');
        left.classes.remove('pY_fullscreen_collapsed');
      }

    } else {
      // open
      button.innerHtml = localization.close;
      bottom.classes.remove('playerBottomCollapsed');
      bottom.classes.remove('playerBottomCollapsed_fullscreen');
      last.classes.remove('opacity30');
      current.classes.remove('opacity30');
      next.classes.remove('opacity30');

      player.classes.remove('pY_collapsed');
      left.classes.remove('pY_collapsed');
      player.classes.remove('pY_fullscreen_collapsed');
      left.classes.remove('pY_fullscreen_collapsed');
      player.classes.add('pY');
      left.classes.add('pY');
      
      bottom.classes.add('playerBottomExp');
    }
    toggleFullscreen.timedRefresh();
  }
  
  void fullScreenEvent(bool state){
    if (state){
      // in fullscreen mode
      toggle(null, !this.open); 
    }     
  }
}

class Sentence {
  String content = "";
  int begin;
  int end;
  
  Sentence(this.content, this.begin, this.end);
}