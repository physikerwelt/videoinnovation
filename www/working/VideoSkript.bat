start /wait WindowsSpeechTranscription.exe %1 video_out_wav 7600
move "transcription.json" "%1\"

xcopy "%1\slidecontent.json"
start /wait keywordAnalyser.jar
move "keywords.json" "%1\"