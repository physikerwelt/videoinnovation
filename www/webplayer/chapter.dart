
part of Webplayer;

class Slide {
  
  String title = '';
  int begin;
  Slide next;
  String searchContent = '';
  int page;
  
  HTML.LIElement element = new HTML.LIElement();
  
  operator == (Slide c){
    return identical(this, c);
  }
  
  
  Slide.fromJSON(Map JSON){
    begin = JSON['timestamp'];
    title = JSON['title'];
    page = JSON['page'];
    if ( JSON['content'] != null){
      searchContent = JSON['content'];
    }
    
    if (title == ""){
      title = " ";
    }
    
    element..innerHtml = title
      ..title = title
      ..classes.add('secondLevel');
    element.onClick.listen(jump);
  }
  
  void jump(HTML.MouseEvent e){
    control.jumpTo(begin);
  }
  
  Slide(){}
  
  bool findMatch(RegExp exp){
    Match titleMatch = exp.firstMatch(title);  // in title
    if (titleMatch == null){
      if (!searchContent.isEmpty){
        Match slideMatch = exp.firstMatch(searchContent); // in slide content
        if (slideMatch != null){
          resetHighlight();
          return true;
        }    
      }
    } else {
      resetHighlight();
      highlightFind(from: titleMatch.start, to:titleMatch.end);
      return true;
    }
    return false;
  }
  
  void highlightFind({int from, int to}){
    String before = '';
    String after = '';
    if (from > 0){
      before = title.substring(0, from);
    }
    
    if (to < title.length){
      after = title.substring(to);
    }
    
    String highlight = title.substring(from, to);
    
    
    String html = '$before<span class="searchHighlight">$highlight</span>$after';
    element.innerHtml = html;
    double offset = element.offsetWidth/title.length;
    offset = offset * from;
    element.scrollLeft = offset.toInt();  // to + 10
    
  }
  

  
  void collapseSlide(){
    element.classes.add('collapsedSlide');
  }
  
  void rolloutSlide(){
    element.classes.remove('collapsedSlide');
  }

  
  void setActive(){
    element.classes.add('activeElement');
    int offset = element.offsetTop;
    int h = element.offsetHeight;
    //element.parentNode.scrollByLines(lines)
    element.parent.scrollTop = offset - 2*h;
  }
  
  void setDeactive(){
    element.classes.remove('activeElement');
  }
  
  void resetHighlight(){
    element
      ..innerHtml = title
      ..classes.remove('fadedSearchEntry')
      ..classes.remove('collapsedSlide')
      ..scrollLeft = 0;
  }
  
  void fade(){
    element.classes.add('fadedSearchEntry');
  }
}


class Chapter extends Slide{
  List<Slide> slides = new List<Slide>();

  Chapter.fromJSON(Map JSON, HTML.UListElement ul){
    begin = JSON['timestamp'];
    title = JSON['title'];
    page = JSON['page'];
    
    
    if ( JSON['content'] != null){
      searchContent = JSON['content'];
    }
    ul.append(element);
    if (JSON['slides'] != null){
      element..innerHtml = title
        ..title = title
        ..classes.add('firstLevel');
      
      
      List jsonSlides = JSON['slides'];
      for (int i=0; i < jsonSlides.length; i++){
        slides.add(new Slide.fromJSON(jsonSlides[i]));
        ul.append(slides[i].element);
      } 
      
    } else {
      element..title = title
        ..innerHtml = title
        ..classes.add('firstLevel');
    }
    element.onClick.listen(jump);
  }
  
  
  void resetHighlight(){
    element
      ..innerHtml = title
      ..classes.remove('fadedSearchEntry')
      ..scrollLeft = 0;
  }
  

  void collapseSlides(){
    slides.forEach((Chapter s)=>s.collapseSlide());
  }
  
  void rolloutSlides(){
    slides.forEach((Chapter s)=>s.rolloutSlide());
  }
}