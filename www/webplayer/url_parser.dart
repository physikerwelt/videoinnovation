part of Webplayer;

class URLParser {
  static HTML.Location loc = HTML.window.location;
  
  static const String page = "?page";
  static const String time = "?time";
  static const String title = "?title";
  
  URLParser(){}
  
  static void parseURL(){
    String search = loc.search;
    if (search != ""){
      List<String> subs = search.split("=");
      if (subs[0] == page){
        control.jumpToSlideByPage(int.parse(subs[1]));
      } else if (subs[0] == time){
        control.jumpTo(convertTime(subs[1]));
      } else if (subs[0] == title){
        String title = subs[1].replaceAll("%20", " "); // Big%20Data%20Analytics -> Big Data Analytics
        control.jumpToSlideByName(title);      
      }
    }    
  }
  
  static int convertTime(String time){
    int timestamp = 0;
    List<String> subs = time.split(new RegExp(r"\D"));
    int k = subs.length-2;
    for (int i=subs.length-2; i >= 0; i--){
      timestamp += int.parse(subs[i]) * Math.pow(60,k-i);
    }
    return timestamp;
  }
  
  static int convTime(String time){
    int timestamp = 0;
    List<String> subs = time.split(new RegExp(r"\D")); 
    int k = subs.length-2;
    for (int i=0; i < subs.length; i++){
      print(subs[i]);
    }
    return timestamp;   
  }
  
  static String linkHere(PlayerWrapper p){
    int t = p.getTimestamp();
    String url = loc.href;
    url = url.split("?")[0];
    url = url+'?time='+t.toString()+'s';
    return url;
  }
  
  static String linkSlide(ChapterControl c){
    String title = c.activeSlide.title;
    String url = loc.href;
    url = url.split("?")[0];
    url = url+'?title=$title';
    return url;
  }
  
  static String linkPdf(ChapterControl c, String pdfUrl){
    String page = c.activeSlide.page.toString();
    return pdfUrl+'#page=$page';
  }
  
}