#include <Array.au3>
#include <file.au3>

const $start = 1
const $end   = 170669
$added = 0
for $id = $start to $end
   clipput('(progress:' & $id & '/' & 170669 & ')')

   if not FileExists(@scriptdir & '\output\' & $id & '.txt') then
	  FileWrite(@scriptdir & '\output\' & $id & '.txt', '')
	  $added += 1
	  clipput('(added: ' & $added & ')')
   endif

next

msgbox(1,'','done')