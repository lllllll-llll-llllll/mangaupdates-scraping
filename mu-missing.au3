#include <Array.au3>
#include <file.au3>


const $_start = 1
const $_end   = 170669
$fails = 0

for $id = $_start to $_end
   $start = 0
   $end   = 0

   if not FileExists(@scriptdir & '\good\' & $id & '.txt') then
	  InetGet('https://www.mangaupdates.com/series.html?id=' & $id, 'html.txt')
	  $html = FileReadToArray('html.txt')

	  for $line = 0 to ubound($html) - 1
		 if $html[$line] = '<!-- Start:Series Info-->' then $start = $line + 1
		 if $html[$line] = '<!-- End:Series Info-->'   then $end = $line - 1
	  next

	  $filename = @scriptdir & '\good\' & $id & '.txt'
	  _FileWriteFromArray($filename, $html, $start, $end)
	  sleep(750)

   endif

next

if $fails > 0 then
   msgbox(1, 'DONE', $fails & ' failed to download.')
else
   msgbox(1, 'DONE', 'everything was downloaded.')
endif













































