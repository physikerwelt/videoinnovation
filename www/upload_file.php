<?php

//
// Dies ist nur eine beispielhafte Implementierung zu Demozwecken.
// Es wird keine Überprüfung des Inhalts gemacht!!
//

$video = $_FILES["video"];
$pdf = $_FILES["pdf"];
$transcription = $_FILES["transcription"];
$agenda = $_POST["agenda"];
$pdfLink = $_POST["pdfLink"];

$x = $_POST["x"];
$y = $_POST["y"];
$width = $_POST["width"];
$height = $_POST["height"];


if ($video["error"] > 0 && $pdf["error"] > 0 && $transcription["error"] > 0) {
	$folderName = basename($video["name"],".mov");
	mkdir($_SERVER['DOCUMENT_ROOT']."/working/".$folderName);
	$path = $_SERVER['DOCUMENT_ROOT']."/working/".basename($video["name"],".mov");
	
	move_uploaded_file($video["temp_name"], $path."VL01.mov");
	move_uploaded_file($pdf["temp_name"], $path."pdf.pdf");
	move_uploaded_file($transcription["temp_name"], $path."transcription.json");
	$config = '{"path":'.$path.', "x":'.$x.',"y":'.$y.',"width":'.$width.',"height":'.$height.',"agenda":'.$agenda.',"pdfLink":'.$pdfLink.'}';
	file_put_contents($path."configuration.json",$config);
	
	exec();
}

?> 