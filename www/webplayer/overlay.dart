part of Webplayer;

class Overlay{
  
  HTML.DivElement overlay = HTML.query('#playerOverlay');
  HTML.InputElement timeInput = HTML.query('#urlLinkTime');
  HTML.InputElement nameInput = HTML.query('#urlLinkSlide');
  HTML.InputElement pdfInput = HTML.query('#urlLinkToPdf');
  HTML.SpanElement closeButton = HTML.query('#closeOverlay');
  
  Overlay(){
    closeButton.onClick.listen((x)=>close());
  }
  
  
  void fill(){
    timeInput.value = URLParser.linkHere(player);
    nameInput.value = URLParser.linkSlide(control);
    pdfInput.value = URLParser.linkPdf(control, pdfUrl);
  }
  
  void close(){
    overlay.classes.remove('open');
    overlay.classes.add('closed');
  }
  
  void open(){
    fill();
    overlay.classes.add('open');
    overlay.classes.remove('closed');   
  }
}