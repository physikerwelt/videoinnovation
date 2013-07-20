library Webplayer;

import 'dart:html' as HTML;
import 'dart:async';
import 'package:web_ui/web_ui.dart';
import 'dart:json' as JSON;
import 'package:js/js.dart' as JS;
import 'dart:math' as Math;

part 'chapter_control.dart';
part 'chapter.dart';
part 'url_parser.dart';
part 'playerwrapper.dart';
part 'transcription.dart';
part 'overlay.dart';
part 'toggle_fullscreen.dart';
part 'localization.dart';


ChapterControl control;
PlayerWrapper player;
String pdfUrl;
Transcription transcription;
Overlay overlay;
ToggleFullscreen toggleFullscreen = new ToggleFullscreen();

Localization localization = new Localization(); 



void main() {
  
  //String href = HTML.window.location.origin;
  HTML.HttpRequest.getString(JS.context.slidecontentUrl).then((String json) => (buildChapterControl(parseJSONList(json))));
  HTML.HttpRequest.getString(JS.context.transcriptionUrl).then((String json) => (buildTranscription(parseJSONList(json))));
  HTML.HttpRequest.getString(JS.context.keywordsUrl).then((String json) => (fillAutocompleteList(parseJSONList(json))));
  HTML.HttpRequest.getString(JS.context.localizationUrl).then((String json) => (localization.update(parseJSON(json))));  
  
  
  pdfUrl = (JS.context.pdfUrl).toString();
  player = new PlayerWrapper();
  
  overlay = new Overlay();

 
  URLParser.parseURL();
  URLParser.linkHere(player);
  
  toggleFullscreen.listen(player.togglePseudoFullScreen);
  
  player.addListenerPlay(overlay.close);
  player.addListenerPause(overlay.open);
  

}


void buildChapterControl(List json){
  control = new ChapterControl.fromJSON(json);
  toggleFullscreen.listen(control.fullScreenEvent);
  toggleFullscreen.listenOnce(control.resize.fullScreenEvent);
  player.addListenerPlaying(control.findActiveSlide);
  player.addListenerSeek(control.findActiveSlide);
}

void buildTranscription(List json){
  transcription = new Transcription.fromJson(json);
  toggleFullscreen.listenOnce(transcription.fullScreenEvent);
  player.addListenerPlaying(transcription.update);
  player.addListenerSeek(transcription.update);
}


Map parseJSON(String jsonString){
  Map data = JSON.parse(jsonString);
  return data;
}

List parseJSONList(String jsonString){
  List data = JSON.parse(jsonString);
  return data;
}

void fillAutocompleteList(List keywords){
  HTML.DataListElement autocomplete = HTML.query('#inputAutocomplete');
  
  for (int i=0; i <keywords.length; i++) {
    HTML.OptionElement el = new HTML.OptionElement();
    el.value = keywords[i];
    autocomplete.append(el);      
  }  
}