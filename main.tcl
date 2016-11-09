#!/bin/sh
# The next line restarts using wish \
exec wish "$0" ${1+"$@"}

package require Tcl
package require Tk
package require Img

set type eur

set menu .menu
menu $menu -tearoff 0
set m $menu.options
menu $m -tearoff 0
$menu add cascade -label "Options" -menu $m -underline 0
$m add command -label "Switch to European version" -command [list game_set eur] -accelerator Ctrl-A
$m add command -label "Switch to English version" -command [list game_set eng] -accelerator Ctrl-S
$m add command -label "Restart game" -command [list game_set ""] -accelerator Ctrl-R

bind . <Control-KeyPress-a> {game_set eur}
bind . <Control-KeyPress-s> {game_set eng}
bind . <Control-KeyPress-r> {game_set ""}

set m $menu.help
menu $m -tearoff 0
$menu add cascade -label "Help" -menu $m -underline 0
$m add command -label "About" -command [list about]

. configure -menu $menu

proc initialise {type} {
  wm title . "Peg Solitaire"
  frame .f
  pack .f -anchor n
  set scriptDir [file join [pwd] [file dirname [info script]]]
  image create photo dot -format png -file [file join $scriptDir data Dot.png]
  image create photo hole -format png -file [file join $scriptDir data Hole.png]
  image create photo blank -format png -file [file join $scriptDir data blank.png]
  
  game_set eur
  
  update idletasks
  wm minsize . [winfo width .] [winfo height .]
  wm maxsize . [winfo width .] [winfo height .]
}

#       European             Enlish
#   0 1 2 3 4 5 6 7 8    0 1 2 3 4 5 6 7 8
# 0 o o o + + + o o o  0 o o o + + + o o o
# 1 o o + + + + + o o  1 o o o + + + o o o
# 2 o + + + + + + + o  2 o o o + + + o o o
# 3 + + + + + + + + +  3 + + + + + + + + +
# 4 + + + + o + + + +  4 + + + + o + + + +
# 5 + + + + + + + + +  5 + + + + + + + + +
# 6 o + + + + + + + o  6 o o o + + + o o o
# 7 o o + + + + + o o  7 o o o + + + o o o
# 8 o o o + + + o o o  8 o o o + + + o o o

set clicked 0
set down ""
proc click {button} {
  global clicked down
  set type [lindex [$button configure -image] 4]
  if {$type eq "hole"} {
    if {$clicked} {
      lassign [split [lindex [split $down "."] end] ""] a b
      lassign [split [lindex [split $button "."] end] ""] x y
      if {$a == $x && [expr {abs(double($b-$y))}] == 2 && [lindex [.f.text.$a[expr {($b+$y)/2}] configure -image] 4] == "dot"} {
        .f.text.$a[expr {($b+$y)/2}] configure -image hole
        $down configure -image hole
        $button configure -image dot
      } elseif {($b == $y && [expr {abs(double($a-$x))}] == 2) && [lindex [.f.text.[expr {($a+$x)/2}]$b configure -image] 4] == "dot"} {
        .f.text.[expr {($a+$x)/2}]$b configure -image hole
        $down configure -image hole
        $button configure -image dot
      }
    }
    set clicked 0
    set down ""
  } else {
    set clicked 1
    set down $button
  }
}

proc game_set {mode} {
  global type
  if {$mode == ""} {set mode $type}
  catch {destroy .f.text {*}[winfo children .f.text]}
  
  text .f.text -relief flat -background "#F0F0F0" -width 43 -height 21
  .f.text configure -state normal
  
  for {set a 0} {$a < 9} {incr a} {
    for {set b 0} {$b < 9} {incr b} {
      switch $mode {
        eur {
          if {[expr {$a+$b}] < 3 || [expr {$a-$b}] > 5 || [expr {$b-$a}] > 5 || [expr {$a+$b}] > 13} {
            button .f.text.$a$b -height 32 -width 32 -image blank -relief flat -overrelief flat
          } else {
            if {$a == 4 && $b == 4} {
              set stat hole
            } else {
              set stat dot
            }
            button .f.text.$a$b -height 32 -width 32 -image $stat -relief flat -overrelief flat -command [list click .f.text.$a$b] -cursor hand2
          }
        }
        eng {
          if {($a < 3 && $b < 3) || ($a < 3 && $b > 5) || ($a > 5 && $b < 3) || ($a > 5 && $b > 5)} {
            button .f.text.$a$b -height 32 -width 32 -image blank -relief flat -overrelief flat
          } else {
            if {$a == 4 && $b == 4} {
              set stat hole
            } else {
              set stat dot
            }
            button .f.text.$a$b -height 32 -width 32 -image $stat -relief flat -overrelief flat -command [list click .f.text.$a$b] -cursor hand2
          }
        }
      }
      .f.text window create end -window .f.text.$a$b
    }
    .f.text insert end "\n"
  }
  pack .f.text -anchor n
  .f.text configure -state disabled
  set type $mode
}

proc about {} {
  set w .credits
  catch {destroy $w}
  toplevel $w
  wm title $w About
  wm geometry $w +200+200
  pack [frame $w.fm] -padx 10 -pady 10
  set w $w.fm
  
  grid [frame $w.fup] -row 0 -column 0
  
  label $w.fup.l1 -text "Author:" -justify left
  label $w.fup.l2 -text "Git:" -justify left
  label $w.fup.l4 -text "Jerry" -justify left
  label $w.fup.l5 -text "https://github.com/Unknown008/Peg-Solitaire" \
    -foreground blue -justify left -font {"Segeo UI" 9 underline}
  bind $w.fup.l5 <ButtonPress-1> {
    eval exec [auto_execok start] "https://github.com/Unknown008/Peg-Solitaire" &
  }

  bind $w.fup.l5 <Enter> [list $w configure -cursor "hand2"]
  bind $w.fup.l5 <Leave> [list $w configure -cursor "ibeam"]
  
  grid $w.fup.l1 -row 0 -column 0 -sticky w
  grid $w.fup.l2 -row 1 -column 0 -sticky w
  grid $w.fup.l4 -row 0 -column 1 -sticky w
  grid $w.fup.l5 -row 1 -column 1 -sticky w
  grid columnconfigure $w 0 -minsize 20
  
  grid [labelframe $w.fdown -padx 2 -pady 2 -text "GNU General Public Licence" \
    -labelanchor n] -row 1 -column 0 -pady 10 -sticky nsew
  text $w.fdown.t -setgrid 1 \
    -height 13 -autosep 1 -background "#F0F0F0" -wrap word -width 63 \
    -font {"Segeo UI" 9} -relief flat
  pack $w.fdown.t -expand yes -fill both -anchor n
  grid rowconfigure $w 1 -weight 1 -minsize 260
  $w.fdown.t insert end "
    Peg Solitaire game written for both European and English versions. Enjoy :)
  "
   
  $w.fdown.t insert end "
    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.
    You should have received a copy of the GNU General Public License
    along with this program. If not, see <http://www.gnu.org/licenses/>
  "
  $w.fdown.t configure -state disabled
  
  grid [ttk::button $w.b -text OK -command [list credits_close $w] \
    -style [ttk::style theme use vista]] -row 2 -column 0
  
  proc credits_close {w} {
    destroy [winfo parent $w]
    focus .
  }
  focus $w
  wm minsize .credits 65 13
  wm maxsize .credits 65 13
}

initialise eur
