#include <array.au3>
#include <file.au3>

;iterate through the pages
const $start = 1 ;1
const $end   = 170669 ;170669


for $i = $start to $end ;170669
   clipput('(progress:' & $i & '/' & 170669 & ')')
   $filename = $i & '.txt'
   $page = FileReadToArray(@scriptdir & '\good\' & $filename)
   ;$page = FileReadToArray(@scriptdir & '\' & $filename)

   ;remove vertical bar characters to avoid issues with formatting
   for $k = 0 to ubound($page) - 1
	  $page[$k] = StringReplace($page[$k], '|', '¦')
   next

   local $fields[0]
   $category = ''
   $recommendation = ''

   ;iterate through the lines
   for $j = 0 to ubound($page) - 1
	  $line = $page[$j]

	  if $j = 2 then ;add title
		 _ArrayAdd($fields, $page[$j])
	  elseif StringInStr($line,'<b>Description</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif $line = '<div style="display:none" id="div_desc_more">' then
		 $fields[1] = $page[$j + 1]
	  elseif StringInStr($line,'<b>Type</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Related Series</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Associated Names</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Completely Scanlated?</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>User Rating</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Genre</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'tag_normal', 1) then
			$category &= $page[$j]	;build up category list
	  elseif StringInStr($line,'<b>Category Recommendations</b>', 1) then
		 _ArrayAdd($fields, $category) ; add categories
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'id="div_recom_link"', 1) or StringInStr($line,'id="div_recom_more"', 1) then
		 $recommendation &= $page[$j + 1]
	  elseif StringInStr($line,'<b>Author(s)</b>', 1) then
		 _ArrayAdd($fields, $recommendation)
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Artist(s)</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Year</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Original Publisher</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  elseif StringInStr($line,'<b>Serialized In (magazine)</b>', 1) then
		 _ArrayAdd($fields, $page[$j + 1])
	  endif
   next

   if ubound($fields) = 0 then continueloop

   ;fields[0]	-	title of the manga
   $regex = StringRegExp($fields[0], 'title">(.*?)<\/span>&', 3)
   $fields[0] = $regex[0]

   ;fields[1]	-	description of the manga			- need to revisit this. it seems there is more than i would expect?
   ;<div class="sContent" style="text-align:justify">N/A
   $fields[1] = StringReplace($fields[1], '<div class="sContent" style="text-align:justify">', '')

   ;fields[2]	-	type (manga, doujinshi, etc)
   ;_ArrayDisplay($fields)
   $string = stringtrimleft($fields[2], 23)
   if $string = '' or $string = 'N/A' then
	  $string = ''
   else
	  $fields[2] = $string
   endif

   ;fields[3]	-	related series
   $string = stringtrimleft($fields[3], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[3] = ''
   else
	  $regex = _arrayunique(StringRegExp($string, "<u>(.*?)</u>", 3), 0, 0, 0, 0)
	  $fields[3] = $regex[0]
   endif

   ;fields[4]	-	associated name
   $string = stringtrimleft($fields[4], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[4] = ''
   else
	  $string = stringreplace($string, '<br />', '|')
	  if StringRight($string, 1) = '|' then $string = stringtrimright($string, 1)
	  $fields[4] = $string
   endif

   ;fields[5]	-	scanlated completely?	-	yes/no
   $string = stringtrimleft($fields[5], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[5] = ''
   else
	  $fields[5] = $string
   endif

   ;fields[6]	-	user rating
   $string = stringtrimleft($fields[6], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[6] = ''
   else
	  $split = stringsplit($string, ' ', 2)
	  $fields[6] = $split[1]
   endif

   ;fields[7]	-	genre
   $string = stringtrimleft($fields[7], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[7] = ''
   else
	  $string = stringreplace($string, '+', ' ')
	  $string = stringreplace($string, '_', ' ')
	  $regex = StringRegExp($string, "genre=(.*?)'", 3)
	  $fields[7] = _ArrayToString($regex, '|')
   endif

   ;fields[8]	-	category
   $string = $fields[8]
   if $string = '' or $string = 'N/A' then
	  $fields[8] = ''
   else
	  $regex = StringRegExp($string, "category=(.*?)'", 3)
	  $fields[8] = _ArrayToString($regex, '|')
   endif

   ;fields[9]	-	category recommendations
   $string = stringtrimleft($fields[9], 23)
   if $string = 'N/A (Add some categories, baka!)' or $string = 'N/A' or $string = '' then
	  $fields[9] = ''
   else
	  ;$regex = StringRegExp($string, "id=(.*?)'", 3)
	  $regex = StringRegExp($string, "<u>(.*?)</u>", 3)
	  $fields[9] = _ArrayToString($regex, '|')
   endif

   ;fields[10]	-	recommendations
   $string = stringtrimleft($fields[10], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[10] = ''
   else
	  ;$regex = _arrayunique(StringRegExp($string, "id=(.*?)'", 3), 0, 0, 0, 0)
	  $regex = _arrayunique(StringRegExp($string, "<u>(.*?)</u>", 3), 0, 0, 0, 0)
	  $fields[10] = _ArrayToString($regex, '|')
   endif

   ;fields[11]	-	author
   $string = stringtrimleft($fields[11], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[11] = ''
   else
	  $regex = StringRegExp($string, "<u>(.*?)</u>", 3)
	  $fields[11] = $regex[0]
   endif

   ;fields[12]	-	artist
   $string = stringtrimleft($fields[12], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[12] = ''
   else
	  $regex = StringRegExp($string, "<u>(.*?)</u>", 3)
	  $fields[12] = $regex[0]									;failed here, check the good to see what the field was, maybe it doesnt have anything? might need to check if anything is there for these things.
   endif

   ;fields[13]	-	year	-	####
   $string = stringtrimleft($fields[13], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[13] = ''
   else
	  $fields[13] = $string
   endif

   ;fields[14]	-	orig publisher
   $string = stringtrimleft($fields[14], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[14] = ''
   else
	  $regex = StringRegExp($string, "<u>(.*?)</u>", 3)
	  $fields[14] = _ArrayToString($regex, '|')
   endif

   ;fields[15]	-	serialized in magazine
   $string = stringtrimleft($fields[15], 23)
   if $string = '' or $string = 'N/A' then
	  $fields[15] = ''
   else
	  $regex = StringRegExp($string, "<u>(.*?)</u>", 3)
	  $fields[15] = _ArrayToString($regex, '|')
   endif







   ;write Files to output
   $output = FileOpen(@scriptdir & '\output\' & $filename, 10)
   _FileWriteFromArray($output, $fields)
   FileClose($output)

next






























   ; title					line 2
   ; description			"<b>Description</b>" + 1
   ; type of media 			"<b>Type</b>" + 1
   ; related series 		"<b>Related Series</b>" + 1
   ; associated names 		"<b>Associated Names</b>" + 1
   ; groups scanlating 		"<b>Groups Scanlating</b>" + 1
   ; latest release 		"<b>Latest Release(s)</b>" + 1
   ; release status 		"<b>Status<div class='d-none d-sm-inline'> in Country of Origin</div></b>" + 1
   ; completely scanlated?  "<b>Completely Scanlated?</b>" + 1
   ; anime start/end ch		"<b>Anime Start/End Chapter</b>" + 1
   ; user rating 			"<b>User Rating</b>" + 1
   ; last updated			"<b>Last Updated</b>" + 1
   ; genre 					"<b>Genre</b>" + 1
   ; categories				"<b>Categories</b>" + X
   ; category recoms		"<b>Category Recommendations</b>" + 1
   ; recommendations		"<b>Recommendations</b>" + ??
   ; author					"<b>Author(s)</b>" + 1
   ; artist					"<b>Artist(s)</b>" + 1
   ; year					"<b>Year</b>" + 1
   ; original publisher		"<b>Original Publisher</b>" + 1
   ; magazine				"<b>Serialized In (magazine)</b> + 1
   ; licensing				"<b>Licensed (in English)</b>" + 1
   ; english publisher		"<b>English Publisher</b>" + 1



