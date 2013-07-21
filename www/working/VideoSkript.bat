start /wait WindowsSpeechTranscription.exe %1 lecture12 2
move "transcription.json" "%1\"

xcopy "%1\slidecontent.json"
start /wait keywordAnalyser.jar
move "keywords.json" "%1\"