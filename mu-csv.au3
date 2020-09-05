#include <Array.au3>
#include <file.au3>

const $start = 1
const $end   = 170669
$csv = fileopen(@scriptdir & '\csv.txt', 9)

for $id = $start to $end
   clipput('(progress:' & $id & '/' & 170669 & ')')
   $input = FileReadToArray(@scriptdir & '\output\' & $id & '.txt')

   if ubound($input) < 10 then
	  ; empty

   else
	  for $i = 0 to ubound($input) - 1
		 $input[$i] = '"' & StringReplace($input[$i], '"', '""') & '"'
	  next

	  $string = _ArrayToString($input, ',') & @crlf
	  clipput($string)
	  FileWrite($csv, $string)
   endif

next

msgbox(1,'','done')