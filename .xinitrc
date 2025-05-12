setxkbmap -option caps:ctrl_modifier -option grp:shifts_toggle
killall xcape
xcape -t 100 -e 'Caps_Lock=Escape'
killall xbindkeys
xbindkeys
unclutter &
xrdb -merge ~/.Xresources
exec i3
