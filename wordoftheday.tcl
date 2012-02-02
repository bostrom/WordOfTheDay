package require tdom
package require http

bind pub - !word pub:wordoftheday

set wotdurl "http://www.urbandictionary.com/"

proc pub:wordoftheday {nick host handle chan text} {
    global wotdurl

    if {[catch {
	set page [::http::data [::http::geturl $wotdurl]]
	set doc [dom parse -html $page]
	set root [$doc documentElement]

	set titleNode [$root selectNodes {//div[@class='word']/a[1]/text()}]

	if {$titleNode == ""} {
	    set titleNode [$root selectNodes {//td[@class='def_word']/a[1]/text()}]
	}

	set title [string trim [[lindex $titleNode 0] nodeValue]]
	putserv "PRIVMSG $chan :Word of the day is: \002$title\002"

	set defs [$root selectNodes {//div[@class='definition']}]
	if {$defs != ""} {
	    set deftextnodes [[lindex $defs 0] selectNodes {self::*//text()}]

	    set examples [$root selectNodes {//div[@class='example']}]
	    set exampletextnodes [[lindex $examples 0] selectNodes {self::*//text()}]

	    set def ""
	    set example ""

	    foreach node $deftextnodes {
		# why doesn't eggdrop output newlines?
		# it just stops outputting when newline comes up
		append def [string map {"\n" " "} [string trim [$node nodeValue]]]
		append def " "
	    }
	    putserv "PRIVMSG $chan :$def"

	    foreach node $exampletextnodes {
		# why doesn't eggdrop output newlines?
		# it just stops outputting when newline comes up
		append example [string map {"\n" " "} [string trim [$node nodeValue]]]
		append example " "
	    }
	    putserv "PRIVMSG $chan :$example"
	} else {
	    set parags [$root selectNodes {//tr[2]//p}]

	    foreach p $parags {
		set text ""
		set textnodes [$p selectNodes {self::*//text()}]
		foreach node $textnodes {
		    # why doesn't eggdrop output newlines?
		    # it just stops outputting when newline comes up
		    append text [string map {"\n" " "} [$node nodeValue]]
		}
		putserv "PRIVMSG $chan :$text"
	    }

	}
    } err]} {
	putserv "PRIVMSG $chan :WotD failed - $err"
    }

}

###################################
putlog "Word Of The Day script loaded!"
###################################
