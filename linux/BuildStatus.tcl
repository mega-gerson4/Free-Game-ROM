# Native Tk dialog for installer results; Read More opens another window.
package require Tk
set result [lindex $argv 0]
set summary [lindex $argv 1]
set logFile [lindex $argv 2]
set fatal [expr {$result ne "success"}]
set heading [expr {$fatal ? "BUILD FATAL ERROR" : "BUILD SUCCESS"}]
set bg "#181119"
set card "#261a26"
set fg "#f8f3f7"
set accent "#f0495c"
wm title . "Trun Game Free Mega - $heading"
wm geometry . 550x270
wm resizable . 0 0
. configure -background $bg
label .header -text $heading -font {Helvetica 21 bold} -foreground $accent -background $bg -anchor w
pack .header -fill x -padx 25 -pady {24 14}
label .summary -text $summary -wraplength 495 -justify left -foreground $fg -background $bg -anchor w
pack .summary -fill both -expand 1 -padx 26
frame .actions -background $bg
pack .actions -fill x -padx 25 -pady {12 20}
proc showDetails {} {
    global heading summary logFile bg fg card accent
    if {[winfo exists .details]} {raise .details; return}
    toplevel .details
    wm title .details "Trun Game Free Mega - Build Details"
    wm geometry .details 780x490
    .details configure -background $bg
    frame .details.area -background $card
    pack .details.area -fill both -expand 1 -padx 10 -pady 10
    text .details.area.text -wrap none -font {Courier 10} -background $card -foreground $fg -insertbackground $fg
    scrollbar .details.area.y -orient vertical -command {.details.area.text yview}
    .details.area.text configure -yscrollcommand {.details.area.y set}
    pack .details.area.y -side right -fill y
    pack .details.area.text -side left -fill both -expand 1
    set logText "No log file available."
    if {[file exists $logFile]} {
        if {![catch {set f [open $logFile r]; set logText [read $f]; close $f}]} { }
    }
    .details.area.text insert end "$heading\n\n$summary\n\n$logText"
    .details.area.text configure -state disabled
}
button .actions.more -text "Read More" -command showDetails -font {Helvetica 11} -background $card -foreground $fg -activebackground $accent -relief flat -width 16
button .actions.close -text "Close" -command exit -font {Helvetica 11} -background $accent -foreground $fg -activebackground $card -relief flat -width 14
pack .actions.more -side left
pack .actions.close -side right
