part of Webplayer;

@observable
class Localization {
  String content; // = 'contents';
  String close; // = 'close';
  String open_transcription; // = 'open transcription';
  String player_fullscreen; // = 'fullscreen';
  String search; // = 'search';
  String urlLinkToPdf; // = 'link3';
  String urlLinkSlide; // = 'link2';
  String urlLinkTime; // = 'link1';
  
  Localization(){}
  
  Localization.fromJSON(Map json){
    content = json['content'];
    close = json['close'];
    open_transcription = json['open transcription'];
    player_fullscreen = json['player fullscreen'];
    search = json['search'];
    urlLinkToPdf = json['urlLinkToPdf'];
    urlLinkSlide = json['urlLinkSlide'];
    urlLinkTime = json['urlLinkTime'];
  }
  
  void update(Map json){
    content = json['content'];
    close = json['close'];
    open_transcription = json['open transcription'];
    player_fullscreen = json['player fullscreen'];
    search = json['search'];
    urlLinkToPdf = json['urlLinkToPdf'];
    urlLinkSlide = json['urlLinkSlide'];
    urlLinkTime = json['urlLinkTime'];   
  }
  
  
}