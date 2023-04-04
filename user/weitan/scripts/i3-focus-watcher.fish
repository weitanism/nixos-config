#!/usr/bin/env fish
#
# Mark last focused window used for later quick switch.
#
# Modified from nicarran's
# comment(https://github.com/i3/i3/issues/838#issuecomment-447289228)

function epochMillis
    math (date +%s%N) / 1000000
end

function main_loop
    set permanenceMs 500
    set lastTime (epochMillis)
    set prevFocus ""
    set prevPrevFocus ""

    while read line
        set currentFocus (echo $line | awk -F' ' '{printf $NF}')
        if test $currentFocus = "0x0"; or test $currentFocus = $prevFocus
            continue
        end
        set currentTime (epochMillis)
        set period (math $currentTime - $lastTime)
        set lastTime $currentTime
        # if the permanence (period) is too small then don't care about the focus change but
        # allow jumping between given two windows at fast speed
        if test $period -gt $permanenceMs; or test $currentFocus = $prevPrevFocus
            if test -n $prevFocus
                i3-msg "[id="$prevFocus"] mark _last" > /dev/null
            end
            set prevPrevFocus $prevFocus
        end
        set prevFocus $currentFocus
    end
end

xprop -root -spy _NET_ACTIVE_WINDOW | main_loop
