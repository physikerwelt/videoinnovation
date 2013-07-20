#!/usr/local/bin/perl

use File::Copy;
use POSIX;

my $Pipeline_Resources = "/home/vagrant/install/pipeline"; # ClassX programs


#input arguments
my $inputvideo = $ARGV[0];				#Videodatei
my $slideDeckFile = $ARGV[1];				#Folien
my $outputFolder = $ARGV[2];				#Ordner fuer Ausgabedatei
my $workFolder = "$outputFolder/working";		#Ordner fuer temporaere Dateien

#Position des Titels in den Slides
my $x = $ARGV[3];			#x-coordinate of the crop area top left corner 
my $y = $ARGV[4];			#y-coordinate of the crop area top left corner
my $W = $ARGV[5];			#width of crop area in pixels
my $H = $ARGV[6];			#height of crop area in pixels

#Position des Inhalts in den Slides
my $cx = $ARGV[7];			#x-coordinate of the crop area top left corner 
my $cy = $ARGV[8];			#y-coordinate of the crop area top left corner
my $cW = $ARGV[9];			#width of crop area in pixels
my $cH = $ARGV[10];			#height of crop area in pixels

my $chapterSlide = $ARGV[11];		#Titel der Kapitelfolie

# Create output streaming directory if it does not exist.
if(!(-e "$outputFolder"))
{
	`mkdir -p $outputFolder`;
	chmod(0777,"$outputFolder");
}

`mkdir -p $workFolder`;					#erstelle temporaeren Ordner
chmod(0777,"$workFolder");

SyncSlides("$workFolder", "$inputvideo", "$Pipeline_Resources", "$slideDeckFile");	#fuehre Slidesynchronisation aus

#`cp $workFolder/SlideMatchingResults.txt $outputFolder`;
`cp $workFolder/output.txt $outputFolder`;	#Kopiere output-Datei in output-Ordner
`rm -r $workFolder`;				#loesche temporaere Datein und Ordner


#####################################################
# subroutines
#####################################################

sub SyncSlides
{
	my $workDir=$_[0];
	my $VideoFileName=$_[1];
	my $Pipeline_Resources=$_[2];
	my $slideFile=$_[3];

	# Step 0: Create slide images from pdf
	if(-e "$workDir/SlideDeck") {
		`rm -rf $workDir/SlideDeck`;
	}
	`mkdir $workDir/SlideDeck`;
	`convert $slideFile -resize 776x582 $workDir/SlideDeck/Slide%03d.jpg`;
	
	if(-e "$workDir/SlideSyncWorkDir") {
		`rm -rf $workDir/SlideSyncWorkDir`;
	}
	
	`mkdir $workDir/SlideSyncWorkDir`;
	`chmod -R 777 $workDir/SlideSyncWorkDir`;

	`mkdir $workDir/SlideSyncWorkDir/SlideDeck`;
	`chmod -R 777 $workDir/SlideSyncWorkDir/SlideDeck`;	
	`cp $workDir/SlideDeck/* $workDir/SlideSyncWorkDir/SlideDeck`;

	##############################################################################
	# Step 1: Rename the slide images in SlideDeck to a monolithic naming scheme #
	##############################################################################
	
	if(-e "$workDir/SlideSyncWovert
rkDir/SlideDeck")
	{
		`rm -rf $workDir/SlideSyncWorkDir/SlideDeck`;
		`mkdir $workDir/SlideSyncWorkDir/SlideDeck`;
		`cp $workDir/SlideDeck/* $workDir/SlideSyncWorkDir/SlideDeck`;
		`chmod -R 777 $workDir/SlideSyncWorkDir/SlideDeck`;
	}
	
	opendir(DIR,"$workDir/SlideSyncWorkDir/SlideDeck");
	my @originalJpgFileNames = grep(/\.jpg$/,readdir(DIR));
	@originalJpgFileNames = sort @originalJpgFileNames;
	closedir(DIR);
	
	my $currentJpgFileIndex=0;
	foreach my $jpgFile(@originalJpgFileNames)
	{
		my $indexString=$currentJPGFileIndex;
		while(length($indexString)<3) {
			$indexString="0".$indexString;
		}
		`mv $workDir/SlideSyncWorkDir/SlideDeck/$jpgFile $workDir/SlideSyncWorkDir/SlideDeck/$indexString.jpg`;
		$currentJPGFileIndex++;
	}
	
	`chmod -R 777 $workDir/SlideSyncWorkDir/SlideDeck`;
	
	##################################################
	# Step 2: Run the slide synchronization function #
	##################################################
	
	opendir(DIR,"$workDir/SlideSyncWorkDir/SlideDeck");
	my @monolithicJpgFileNames = grep(/\.jpg$/,readdir(DIR));
	@monolithicJpgFileNames = sort @monolithicJpgFileNames;
	closedir(DIR);
	my $numSlides=@monolithicJpgFileNames;

	# Create the Param File
	open (MYFILE, ">$workDir/SlideSyncParamFile.txt");
	print MYFILE "1920\n1080\n";
	print MYFILE "$Pipeline_Resources/SlideSynchronization/sift\n";
	print MYFILE "$Pipeline_Resources/SlideSynchronization/image_matching\n";
	print MYFILE "$workDir/SlideSyncWorkDir/SlideDeck/\n";
	print MYFILE "$numSlides\n";
	print MYFILE "50\n776\n582\n";
	print MYFILE "$Pipeline_Resources/SlideSynchronization/slideMatch\n";
	print MYFILE "$VideoFileName\n";
	print MYFILE "12\n"; # This parameter may need to be tuned
	print MYFILE "$workDir/SlideSyncWorkDir/\n";
	print MYFILE "-1";
	close(MYFILE);
	`chmod 777 $workDir/SlideSyncParamFile.txt`;

	# Perform the Slide Sync
	system("$Pipeline_Resources/SlideSynchronization/processExt_extract_sift_fr_jpg $workDir/SlideSyncWorkDir/SlideDeck/ $Pipeline_Resources");
	system("$Pipeline_Resources/SlideSynchronization/changeDetect $workDir/SlideSyncParamFile.txt");
	system("$Pipeline_Resources/SlideSynchronization/slideMatch $workDir/SlideSyncParamFile.txt");

	`cp $workDir/SlideSyncWorkDir/resultsOut.txt $workDir/SlideMatchingResults.txt`;
	`cp $workDir/SlideSyncWorkDir/resultsOut_model.txt $workDir/TransformationModels.txt`;
	`chmod 777 $workDir/SlideMatchingResults.txt`;
	
	######################################
	# Step 3: Generate SlideInfoFile.txt #
	######################################
	
#Titel aus Folien auslesen
`pdftotext -q -x $x -y $y -W $W -H $H $slideFile $workDir/titles.txt`;

open(TITLEFILE,"$workDir/titles.txt");

my $title = "";		#Folientitel
my @array = ();		#Array mit allen ausgelesenen Folientitel
my @chapter = ();	#Array mit Kapitelnamen

my $countSlide = 0;	#Foliennummer
my $readChapter = 1;	#Flag

while(($c=getc(TITLEFILE)) ne ""){
	if($c eq ""){
		$countSlide = $countSlide +1;
		push(@array, $title);	#Titel in Array speichern
		if($readChapter && ($title eq $chapterSlide)){	#Kapitelnamen sollen ausgelesen werden
			$readChapter = 0;

			`pdftotext -q -f $countSlide -l $countSlide -x $cx -y $cy -W $cW -H $cH -nopgbrk -layout $slideFile '$workDir/chapter.txt'`;#Kapitel aus Folien auslesen
			open(CHAPTERFILE,"$workDir/chapter.txt");
			@chapter=<CHAPTERFILE>;	#Kapitelnamen speichern
			chomp @chapter;
			close(CHAPTERFILE);

		}
		$title="";
	}
	else{
		if($c ne "\n"){
			$title = $title . $c ;
		}
	}
}

close TITLEFILE;

##################
#get slide content
##################

my $slidecontent= "";
my @content = ();


for($p=1; $p<=$countSlide; $p++){
	`pdftotext -q -f $p -l $p -x $cx -y $cy -W $cW -H $cH -nopgbrk $slideFile $workDir/content.txt`;	#Folieninhalt auslesen
	open(CONTENTFILE,"$workDir/content.txt");

	my @con =<CONTENTFILE>;
	#chomp @con;
	my $n = @con;

	my $m;
	for ($m=0; $m<$n; $m++){
		$slidecontent = $slidecontent . $con[$m];
	}

	$slidecontent =~ s/\s+/ /g;	#Leerzeichen entfernen

	push(@content, $slidecontent);
	$slidecontent="";

	close CONTENTFILE;
}


##############
#match results
##############
	open(matchingFileLines,"$workDir/SlideMatchingResults.txt");

	my @matchingAllLines=<matchingFileLines>;

	chomp @matchingAllLines;	#remove "\n"

	my $numMatchingLines=@matchingAllLines;

	if($numMatchingLines<2)
	{
		exit(5);
	}
	#create output.txt
	my $lastSlide = -2;
	my $framerate = 30;	#videoframerate

	my $in_chapter = 0;
	my $count_chap=0;
	my $set_comma=0;
	my $lastChapterPage=-1;

	open (MYFILE, ">$workDir/slidecontent.json");	#erstelle ouputdatei
	print MYFILE "[";
	for($i=0;$i<$numMatchingLines;$i++)
	{
		my @currentEvent=split(/\t/,$matchingAllLines[$i]);
		
		if($lastSlide != $currentEvent[1] && $currentEvent[1] >= 0 && $currentEvent[2]>100){	#nicht die gleiche Folie 2x && nur wenn Folie zu sehen ist (sonst -1) && uebereinstimmung gross genug


			my $time = floor($currentEvent[0]/$framerate);	#berechne Zeit in sec
			my $name = $array[$currentEvent[1]];		#hole Folientitel
			my $cont = $content[$currentEvent[1]];
			my $page = $currentEvent[1]+1;

			if(($name eq $chapterSlide) && $lastChapterPage < $page){
				$lastChapterPage = $page;
				if($in_chapter==1){
					print MYFILE "]}";
				}
			$in_chapter = 1;
			if($set_comma==1){
				print MYFILE ", ";
			}
			print MYFILE "{\"title\": \"$chapter[$count_chap]\", \"page\": $page, \"timestamp\": $time, \"slides\": [";
$count_chap=$count_chap+1;	
$set_comma=0;
			}
			else{
			if($set_comma==1){
				print MYFILE ", ";
			}
			print MYFILE "{\"title\": \"$name\", \"page\": $page, \"content\": \"$cont\", \"timestamp\": $time}";
				$set_comma=1;
			}
			

			$lastSlide = $currentEvent[1];
		}		
	}
	if($in_chapter==1){
		print MYFILE "]}";
	}
	print MYFILE "]";
	close(MYFILE);
	`chmod 777 $workDir/output.txt`;

	close(matchingFileLines);
	
}

################################################################################
