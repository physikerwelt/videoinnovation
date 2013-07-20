part of Webplayer;

class ChapterControl {
  
  List<Chapter> chapters = new List<Chapter>();
  Search search;
  ContentResizer resize;
  HTML.DivElement contentDiv;
  HTML.UListElement contentList;
  HTML.DataListElement autocomplete;
  Slide activeSlide;
  HTML.DivElement body;
  HTML.DivElement playerhub;
  
  int defaultWidth;
  int defaultHeight;

  
  ChapterControl.fromJSON(List jsonChapters){
    
    contentDiv = HTML.query('#contentListDiv');
    contentList = HTML.query('#contentList');
    autocomplete = HTML.query('#inputAutocomplete');
    body = HTML.query('#bodyWrapper');
    playerhub = HTML.query('#playerhub');

    
    for (int i=0; i < jsonChapters.length; i++){ 
      chapters.add(new Chapter.fromJSON(jsonChapters[i], contentList));
    }
    
    
    defaultHeight = playerhub.offsetHeight;
    defaultWidth = playerhub.offsetWidth;


    search = new Search(chapters);
    resize = new ContentResizer(this);
    // add fullscreen button to jwplayer
    JS.context.jwplayer().addButton(JS.context.icon, JS.context.tooltip, new JS.Callback.many(()=>toggleFullscreen()), "controlB1");  //new JS.Callback.many((o)=>toggleFullScreen())

  }
  
  
  void findActiveSlide(int timestamp){
    int i = chapters.length;
    Chapter c;
    while(i-- > 0){
      if (chapters[i].begin <= timestamp){
        c = chapters[i];
        break;
      }
    }
    
    
    i = c.slides.length;
    while(i-- > 0){
      if (c.slides[i].begin <= timestamp){
        return setActiveSlide(c.slides[i]);
      }
    }
    return setActiveSlide(c);
  }
  
  void setActiveSlide(Slide slide){
    if (activeSlide == null){
      activeSlide = slide;
      activeSlide.setActive();
    } 
    else if (slide != activeSlide){
      activeSlide.setDeactive();
      activeSlide = slide;
      activeSlide.setActive();
    }
  }
  
  void jumpTo(int timestamp, [bool start =  false]){
    if (start){
      JS.context.startParam = timestamp;
    } else {
      findActiveSlide(timestamp);
      player.jumpTo(timestamp);    
    }
  }
  
  void jumpToSlideByName(String name, [bool start = false]){
    for (int i=0; i < chapters.length; i++){
      if (chapters[i].title == name){
        return jumpTo(chapters[i].begin, start);
      } else {
        for (int k=0; k < chapters[i].slides.length; k++){
          if (chapters[i].slides[k].title == name){
            return jumpTo(chapters[i].slides[k].begin, start);
          }
        }
      }
    }
  }
  
  void jumpToSlideByPage(int page, [bool start = false]){
    for (int i=0; i < chapters.length; i++){
      if (chapters[i].page == page){
        return jumpTo(chapters[i].begin, start);
      } else {
        for (int k=0; k < chapters[i].slides.length; k++){
          if (chapters[i].slides[k].page == page){
            return jumpTo(chapters[i].slides[k].begin, start);
          }
        }
      }
    }
  }
  
  String getPDFLinkToActiveChapter(){
    return '$pdfUrl#page=${activeSlide.page}';
  }
  
  void fullScreenEvent(bool state){
    if (state){
      // enter fullscreen mode
      playerhub.classes.remove('defaultSize');
      playerhub.classes.add('maxSize');
      playerhub.requestFullscreen();
    } else {
      // fullscreen mode left
      playerhub.classes.add('defaultSize');
      playerhub.classes.remove('maxSize');
      HTML.document.cancelFullScreen();
    }
  }
  
}

class Search {
  HTML.DivElement div;
  HTML.InputElement input;    //TextInputElement

  List<Slide> lookUp = new List<Slide>();  
  List<Slide> history = new List<Slide>();
  
  Search(List<Chapter>chapters){
    div = HTML.query('#searchField');
    input = div.children[0];
    for (int i=0; i < chapters.length; i++){
      lookUp.add(chapters[i]);
      for (int k=0; k < chapters[i].slides.length; k++){
        lookUp.add(chapters[i].slides[k]);
      }
    }
    input.onKeyUp.listen(startSearch);
  }
  
  
  void startSearch(HTML.KeyboardEvent e){
    // track backspace(8) and enter(13)
    if (input.value.isEmpty == true){
      restoreContentList();
    } else if (e.which == 13) {
      resetSearch(input.value);
    } else if (e.which == 8){
      rewindSearch(input.value);
    } else {
      find(input.value);
    }
  }
  
  void resetSearch(String query){
    restoreContentList();
    find(query);
  }
  
  void rewindSearch(String query){
    int i = history.length;
    RegExp exp = new RegExp(query, multiLine: true, caseSensitive: false);
    while (i-- > 0){
      if (history[i].findMatch(exp) == true){
        Slide l = history.removeAt(i);
        lookUp.add(l);
      } else {
        history[i]..resetHighlight()
            ..fade();
        break;
      }
    }
    find(query);
  }
  
  void find(String query){
    RegExp exp = new RegExp(query, multiLine: true, caseSensitive: false);
    int i = lookUp.length;
    while(i-- > 0){
      if (lookUp[i].findMatch(exp) == false){
        Slide l = lookUp.removeAt(i);
        l.resetHighlight();
        l.fade();
        history.add(l);
      }
    }
  }
 
  restoreContentList(){
    int i = history.length;
    while (i-- > 0){
      lookUp.add(history.removeLast());
    }
    for (int k=0; k < lookUp.length; k++){
      lookUp[k].resetHighlight();
    }
  }
}

class ContentResizer {
  
  HTML.DivElement leftParent;
  HTML.DivElement div;
  HTML.DivElement contentList;
  HTML.DivElement search;
  HTML.DivElement player;
  HTML.DivElement bottom;
  String standardText;
  String shortText = '<<';
  bool open = true;
  ChapterControl parent;
  
  ContentResizer(ChapterControl parent){
    div = HTML.query('#resizeLeft');
    leftParent = HTML.query('#left');
    contentList = HTML.query('#contentListDiv');
    search = HTML.query('#searchField');
    player = HTML.query('#player');
    bottom = HTML.query('#playerBottom');
    leftParent.classes.add('leftExpanded');
    standardText = localization.content;
    div.onClick.listen(toggle);
    this.parent = parent;
  }
  
  toggle(HTML.MouseEvent e, [bool open]){
    if (open == null){
      open = this.open;
      this.open = !open;
    }
    if (open){
      // close left panel
      div.innerHtml = shortText;
      div.classes.add('resizeLeftCollapsed');
      contentList.classes.add('opacity30');
      search.classes.add('opacity30');
      
      player.classes.remove('pX');
      bottom.classes.remove('pX');  
      
      if (toggleFullscreen.inFullscreenMode){
        // fullscreen is active
        leftParent.classes.add('leftCollapsed_fullscreen');
        player.classes.add('pX_fullscreen_collapsed');
        bottom.classes.add('pX_fullscreen_collapsed');
        leftParent.classes.remove('leftCollapsed');
        player.classes.remove('pX_collapsed');
        bottom.classes.remove('pX_collapsed');
      } else {
        leftParent.classes.add('leftCollapsed');
        player.classes.add('pX_collapsed');
        bottom.classes.add('pX_collapsed');
        leftParent.classes.remove('leftCollapsed_fullscreen');
        player.classes.remove('pX_fullscreen_collapsed');
        bottom.classes.remove('pX_fullscreen_collapsed');
      }
    } else {
      // open left panel
      div.innerHtml = standardText;
      div.classes.remove('resizeLeftCollapsed');
      contentList.classes.remove('opacity30');
      search.classes.remove('opacity30');
      player.classes.add('pX');
      bottom.classes.add('pX');  
      player.classes.remove('pX_fullscreen_collapsed');
      player.classes.remove('pX_collapsed');
      bottom.classes.remove('pX_fullscreen_collapsed');
      bottom.classes.remove('pX_collapsed');     
      leftParent.classes.remove('leftCollapsed');
      leftParent.classes.remove('leftCollapsed_fullscreen');
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