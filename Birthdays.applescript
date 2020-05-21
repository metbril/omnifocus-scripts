(* 
==========
Name		: Add Birthdays to OmniFocus
Description	: Add a task to OmniFocus Inbox for contacts with close birthdays
Author		: Robert van Bregt (https://robertvanbregt.nl/)

Known bugs and features:
  - Task name and notes in Dutch
  - Fixed defer time of 00:00 and due time of 20:00
  - Tested with OF 3.6.4 / MacOS 10.15.4

2020-05-21
  - Initial script.
  
========== 
*)

-- days to look ahead
property AHEAD : 7

set cdt to (current date)
set cyr to year of (current date)

set s to date string of (current date)
-- display notification s


tell application "Contacts"
	
	-- get all people with a birth date
	set thePeople to every person whose birth date is not missing value
	if (count of thePeople) = 0 then
		display dialog "No people with birth date."
		return
	end if
	
	repeat with thePerson in thePeople
		
		set bdt to birth date of thePerson
		set byr to year of bdt
		
		-- get this year's birthday from birth date
		set bdy to bdt
		set year of bdy to cyr
		
		if (bdy is greater than cdt) and (bdy is less than (cdt + AHEAD * days)) then
			
			log "Matching birth day: " & short date string of bdy
			
			if (byr = 1604) then -- unknown year
				set age to "zoveelste"
			else
				set age to (cyr - byr) & "e"
			end if
			
			set task_name to "Feliciteren " & (name of thePerson) & " met " & age & " verjaardag"
			
			-- DRY is impossible for phone and email
			-- putting the redundant code in a function raises an error
			
			set theList to (phone of thePerson)
			set allItems to ""
			repeat with theItem in theList
				set theLabel to (label of theItem)
				set theLabel to my removeGarbageFromLabel(theLabel)
				set theValue to (value of theItem)
				set allItems to allItems & theLabel & ": " & theValue & "
"
			end repeat
			set task_phone to allItems
			
			set theList to (email of thePerson)
			set allItems to ""
			repeat with theItem in theList
				set theLabel to (label of theItem)
				set theLabel to my removeGarbageFromLabel(theLabel)
				set theValue to (value of theItem)
				set allItems to allItems & theLabel & ": " & theValue & "
"
			end repeat
			set task_email to allItems
			
			set task_defer to bdy - 12 * hours
			set task_due to bdy + 8 * hours
			
			
			set task_note to "---
Van harte gefeliciteerd met je " & age & " verjaardag. Geniet van je dag.
---
" & task_phone & "
" & task_email & "
---"
			
			
			
			
			tell application "OmniFocus"
				tell default document
					make new inbox task with properties Â
						Â
							{name:task_name, note:task_note, defer date:task_defer, due date:task_due} Â
								
				end tell
			end tell
		end if
		
	end repeat
end tell

on findAndReplaceInText(theText, theSearchString, theReplacementString)
	set AppleScript's text item delimiters to theSearchString
	set theTextItems to every text item of theText
	set AppleScript's text item delimiters to theReplacementString
	set theText to theTextItems as string
	set AppleScript's text item delimiters to ""
	return theText
end findAndReplaceInText

on removeGarbageFromLabel(theLabel)
	set theLabel to my findAndReplaceInText(theLabel, "_$!<", "")
	set theLabel to my findAndReplaceInText(theLabel, ">!$_", "")
	return theLabel
end removeGarbageFromLabel

