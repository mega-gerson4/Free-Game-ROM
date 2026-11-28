#!/usr/bin/env wish
# Trun Game Free Mega - native Tcl/Tk desktop UI on Linux (no Python, no browser UI)
package require Tk
namespace eval app {
  variable root [file normalize [file join [file dirname [info script]] ..]]
  variable data [file join $::env(HOME) .local share TrunGameFreeMega DataSense]
  file mkdir $data
  variable history [file join $data history.tsv]
  variable prefs [file join $data language.txt]
  variable entries {}
  variable group All
  variable search ""
  variable setting auto
  variable status Ready
  variable groups {All Nintendo Sony Microsoft Sega Capcom Commodore}
  variable t
  array set t {
    en,all {All games} pt,all {Todos} es,all {Todos} fr,all {Tous} de,all {Alle} ja,all {All games}
    en,search {Search consoles or links...} pt,search {Buscar consoles ou links...} es,search {Buscar consolas o enlaces...} fr,search {Rechercher des liens...} de,search {Links suchen...} ja,search {Search games...}
    en,copy COPY pt,copy COPIAR es,copy COPIAR fr,copy COPIER de,copy KOPIEREN ja,copy COPY
    en,open OPEN pt,open ABRIR es,open ABRIR fr,open OUVRIR de,open OEFFNEN ja,open OPEN
    en,history HISTORY pt,history HISTORICO es,history HISTORIAL fr,history HISTORIQUE de,history VERLAUF ja,history HISTORY
    en,creators CREATORS pt,creators CRIADORES es,creators CREADORES fr,creators CREATEURS de,creators ERSTELLER ja,creators CREATORS
    en,copied {Copied to clipboard} pt,copied {Copiado para area de transferencia} es,copied {Copiado al portapapeles} fr,copied {Lien copie} de,copied {In Zwischenablage kopiert} ja,copied {Copied to clipboard}
    en,clear {Clear history} pt,clear {Apagar historico} es,clear {Borrar historial} fr,clear {Effacer historique} de,clear {Verlauf loeschen} ja,clear {Clear history}
    en,empty {No results} pt,empty {Nenhum resultado} es,empty {Sin resultados} fr,empty {Aucun resultat} de,empty {Keine Treffer} ja,empty {No results}
  }
}
proc app::code {} {
  variable setting
  if {$setting ne "auto"} {return $setting}
  foreach e {LC_ALL LC_MESSAGES LANG XKB_DEFAULT_LAYOUT} {
    if {[info exists ::env($e)] && [string length $::env($e)] >= 2} {
      set code [string tolower [string range $::env($e) 0 1]]
      if {$code in {en pt es fr de ja}} {return $code}
    }
  }
  return en
}
proc app::tx {key} {
  variable t
  set index "[code],$key"
  if {[info exists t($index)]} {return $t($index)}
  return $t(en,$key)
}
proc app::load {} {
  variable root; variable entries; variable prefs; variable setting
  if {[file exists $prefs]} {
    set f [open $prefs r]; set val [string trim [read $f]]; close $f
    if {$val in {auto en pt es fr de ja}} {set setting $val}
  }
  set catalog [file join $root catalog.tsv]
  set f [open $catalog r];fconfigure $f -encoding utf-8
  gets $f
  while {[gets $f line] >= 0} {
    set cols [split $line "\t"]
    if {[llength $cols] != 3} continue
    lappend entries $cols
  }
  close $f
}
proc app::copy {name url} {
  variable history; variable status
  clipboard clear
  clipboard append -- $url
  update idletasks
  set f [open $history a]
  fconfigure $f -encoding utf-8
  puts $f "[clock format [clock seconds] -format {%Y-%m-%d %H:%M:%S}]\t$name\t$url"
  close $f
  set status "[tx copied]: $name"
}
proc app::openURL {url} {
  variable status
  if {[catch {exec xdg-open $url &} err]} {set status "Unable to open: $err"}
}
proc app::setGroup {x} { variable group;set group $x;render }
proc app::saveLanguage {} {
  variable setting; variable prefs
  set label $::app::choice
  set codes {Auto auto English en Portugues pt Espanol es Francais fr Deutsch de Japanese ja}
  if {[dict exists $codes $label]} {set setting [dict get $codes $label]}
  set f [open $prefs w];puts $f $setting;close $f
  render
}
proc app::render {} {
  variable entries; variable group; variable search; variable status
  variable navButtons
  foreach x $::app::groups {
    set b $navButtons($x)
    $b configure -bg [expr {$x eq $group ? "#EF4D63" : "#231823"}]
    if {$x eq "All"} {$b configure -text [tx all]}
  }
  foreach child [winfo children .base.content.scroller.area] {destroy $child}
  .base.content.top.hist configure -text [tx history]
  set count 0
  set query [string tolower [string trim $search]]
  foreach item $entries {
    lassign $item category name url
    if {$group ne "All" && $category ne $group} continue
    if {$query ne "" && [string first $query [string tolower "$name $url $category"]] < 0} continue
    incr count
    set row [frame .base.content.scroller.area.r$count -bg #231823 -height 65]
    pack $row -fill x -padx 12 -pady 4
    pack propagate $row false
    set left [frame $row.labels -bg #231823]
    pack $left -side left -fill both -expand 1 -padx 14 -pady 7
    label $left.group -text [string toupper $category] -fg #F04F62 -bg #231823 -anchor w -font {Arial 9 bold}
    pack $left.group -fill x
    label $left.name -text $name -fg #FFF4F7 -bg #231823 -anchor w -font {Arial 11}
    pack $left.name -fill x
    button $row.open -text [tx open] -width 8 -fg white -bg #3D2B3B -relief flat -activebackground #584357 -command [list app::openURL $url]
    pack $row.open -side right -padx {0 10} -pady 13 -ipady 5
    button $row.copy -text [tx copy] -width 10 -fg white -bg #E94660 -relief flat -activebackground #FF657A -command [list app::copy $name $url]
    pack $row.copy -side right -padx {0 8} -pady 13 -ipady 5
  }
  if {$count==0} {
    label .base.content.scroller.area.empty -text [tx empty] -fg #C0ABB8 -bg #110E16 -font {Arial 13}
    pack .base.content.scroller.area.empty -pady 38
  }
  .base.content.count configure -text "$count / [llength $entries] LINKS"
}
proc app::historyWindow {} {
  variable history
  if {[winfo exists .history]} {raise .history;return}
  toplevel .history
  wm title .history "DataSense - History"
  wm geometry .history 680x430
  .history configure -bg #110E16
  text .history.records -bg #231823 -fg white -font {Courier 10} -wrap word -relief flat
  pack .history.records -fill both -expand 1 -padx 15 -pady 15
  if {[file exists $history]} {
    set f [open $history r];fconfigure $f -encoding utf-8
    .history.records insert end [read $f];close $f
  }
  .history.records configure -state disabled
  button .history.clear -text [tx clear] -bg #E94660 -fg white -command app::clearHistory
  pack .history.clear -padx 15 -pady {0 12} -anchor e
}
proc app::clearHistory {} {
  variable history; variable status
  if {[tk_messageBox -type yesno -icon question -message "Delete your local copy history?"] ne "yes"} return
  if {[file exists $history]} {file delete -- $history}
  if {[winfo exists .history]} {.history.records configure -state normal;.history.records delete 1.0 end;.history.records configure -state disabled}
  set status "DataSense: history cleared"
}
proc app::creators {} {
  variable root
  set f [open [file join $root credits.txt] r];fconfigure $f -encoding utf-8
  set contents [read $f];close $f
  tk_messageBox -title "Trun Game Free Mega - Creators" -message $contents -type ok
}
app::load
wm title . "Trun Game Free Mega 2.2"
wm geometry . 1080x730
wm minsize . 900 600
. configure -bg #110E16
set iconpath [file join $::app::root assets MEGA-Logo.png]
if {[file exists $iconpath]} {
  image create photo ::app::logo -file $iconpath
  wm iconphoto . ::app::logo
}
frame .head -bg #231823 -height 127
pack .head -side top -fill x
pack propagate .head false
frame .head.top -bg #231823
pack .head.top -fill both -expand 1
if {[lsearch -exact [image names] ::app::logo] >= 0} {
  image create photo ::app::smlogo
  ::app::smlogo copy ::app::logo -subsample 2 2
  label .head.top.logo -image ::app::smlogo -bg #231823
  pack .head.top.logo -side left -padx {25 18} -pady 10
}
frame .head.top.words -bg #231823
pack .head.top.words -side left -fill y -pady 24
label .head.top.words.title -text "TRUN GAME FREE MEGA" -bg #231823 -fg #FFFFFF -font {Arial 24 bold}
pack .head.top.words.title -anchor w
label .head.top.words.subtitle -text "RED EDITION  /  2.2  /  NATIVE APP" -bg #231823 -fg #F04F62 -font {Arial 11 bold}
pack .head.top.words.subtitle -anchor w -pady {5 0}
frame .accent -bg #F04F62 -height 3
pack .accent -side top -fill x
frame .base -bg #110E16
pack .base -fill both -expand 1
frame .base.sidebar -bg #231823 -width 210
pack .base.sidebar -side left -fill y
pack propagate .base.sidebar false
label .base.sidebar.title -text "LIBRARY" -bg #231823 -fg #F04F62 -font {Arial 11 bold}
pack .base.sidebar.title -anchor w -padx 23 -pady {23 13}
foreach g $::app::groups {
  set slug [string tolower $g]
  button .base.sidebar.$slug -text $g -anchor w -bg #231823 -fg white -activebackground #F04F62 -relief flat -borderwidth 0 -padx 12 -pady 12 -font {Arial 11 bold} -command [list app::setGroup $g]
  pack .base.sidebar.$slug -fill x -padx 9 -pady 2
  set ::app::navButtons($g) .base.sidebar.$slug
}
button .base.sidebar.creators -text CREATORS -bg #342634 -fg white -activebackground #F04F62 -relief flat -command app::creators
pack .base.sidebar.creators -fill x -padx 18 -pady {28 7} -ipady 9
label .base.sidebar.status -textvariable ::app::status -bg #231823 -fg #C0AAB9 -anchor sw -wraplength 180
pack .base.sidebar.status -side bottom -fill x -padx 18 -pady 19
frame .base.content -bg #110E16
pack .base.content -side left -fill both -expand 1
frame .base.content.top -bg #110E16 -height 89
pack .base.content.top -fill x
pack propagate .base.content.top false
entry .base.content.top.search -textvariable ::app::search -font {Arial 12} -bg #322332 -fg white -insertbackground white -relief flat
pack .base.content.top.search -side left -fill x -expand 1 -padx {23 10} -pady 25 -ipady 8
bind .base.content.top.search <KeyRelease> {app::render}
set names {Auto English Portugues Espanol Francais Deutsch Japanese}
set cur 0
set codes {auto en pt es fr de ja}
set idx [lsearch -exact $codes $::app::setting]
if {$idx >= 0} {set cur $idx}
set ::app::choice [lindex $names $cur]
ttk::combobox .base.content.top.lang -values $names -state readonly -width 12 -textvariable ::app::choice
pack .base.content.top.lang -side left -pady 24 -padx {0 9}
bind .base.content.top.lang <<ComboboxSelected>> {app::saveLanguage}
button .base.content.top.hist -text HISTORY -command app::historyWindow -fg white -bg #E94660 -relief flat -activebackground #FF657A -font {Arial 10 bold}
pack .base.content.top.hist -side left -pady 24 -padx {0 18} -ipadx 8 -ipady 5
label .base.content.count -bg #110E16 -fg #BFA8B6 -anchor w -font {Arial 10 bold}
pack .base.content.count -fill x -padx 27 -pady {0 10}
frame .base.content.scroller -bg #110E16
pack .base.content.scroller -fill both -expand 1
canvas .base.content.scroller.canvas -bg #110E16 -highlightthickness 0 -bd 0
scrollbar .base.content.scroller.bar -orient vertical -command ".base.content.scroller.canvas yview"
.base.content.scroller.canvas configure -yscrollcommand ".base.content.scroller.bar set"
pack .base.content.scroller.bar -side right -fill y
pack .base.content.scroller.canvas -side left -fill both -expand 1
frame .base.content.scroller.area -bg #110E16
set areaid [.base.content.scroller.canvas create window 0 0 -anchor nw -window .base.content.scroller.area]
bind .base.content.scroller.area <Configure> {.base.content.scroller.canvas configure -scrollregion [.base.content.scroller.canvas bbox all]}
bind .base.content.scroller.canvas <Configure> {.base.content.scroller.canvas itemconfigure $::areaid -width %w}
bind .base.content.scroller.canvas <MouseWheel> {.base.content.scroller.canvas yview scroll [expr {-%D / 120}] units}
bind .base.content.scroller.canvas <Button-4> {.base.content.scroller.canvas yview scroll -3 units}
bind .base.content.scroller.canvas <Button-5> {.base.content.scroller.canvas yview scroll 3 units}
bind . <Return> {break}
app::render
