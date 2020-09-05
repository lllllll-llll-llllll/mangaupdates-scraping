#include <array.au3>
#include <file.au3>

$prev = ''
$this = ''

for $id = 150000 to 170669
   $start = 0
   $end   = 0

   ;download page
   InetGet('https://www.mangaupdates.com/series.html?id=' & $id, 'html.txt')
   $html = FileReadToArray('html.txt')
   ;_arraydisplay($html)

   ;trim the page down to only relevant info section
   for $line = 0 to ubound($html) - 1
	  if $html[$line] = '<!-- Start:Series Info-->' then $start = $line + 1
	  if $html[$line] = '<!-- End:Series Info-->'   then $end = $line - 1
   next

   $this = $html[4]
   if $this = $prev then
	  ;$filename = @scriptdir & '\bad\' & $id & '.txt'
	  ;FileWrite($filename, '')
	  sleep(8000)
   else
	  ;write page to folder
	  $filename = @scriptdir & '\good\' & $id & '.txt'
	  _FileWriteFromArray($filename, $html, $start, $end)
	  sleep(1000)
   endif

   $prev = $this

next
