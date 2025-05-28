killall xcape
killall xbindkeys
killall syncthing
setxkbmap -option caps:ctrl_modifier -option grp:shifts_toggle
xcape -t 100 -e 'Caps_Lock=Escape'
xbindkeys
unclutter &
syncthing --no-browser &
xrdb -merge ~/.Xresources
exec i3
