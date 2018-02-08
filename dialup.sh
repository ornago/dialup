#!/bin/bash

if ping -c 1 8.8.8.8 &> /dev/null
then
    echo "Internet Connection already established"

    sleep 5

    if ping -c 1 10.8.0.1 &> /dev/null
    then
        echo "OpenVPN connected already"
    else
        echo "Internet found, but no OpenVPN"
        systemctl restart openvpn-client@shootfor.service
    fi
else
    echo "Internet Connection missing"
    if ls -l /dev/gsmmodem | grep "[t]tyUSB" &> /dev/null
    then
        echo "GSMModem link found, checking wvdial pinstatus"
        if wvdial pinstatus 2>&1 | grep -q "[+]CPIN: SIM PIN" &> /dev/null
        then
            echo "Pin Missing"
            tmux new -d 'wvdial pin'
            sleep 10
            tmux new -d 'wvdial aldi'
        else
            echo "PIN already used"
            tmux new -d 'wvdial aldi'
        fi

        sleep 30

        if ping -c 1 8.8.8.8 &> /dev/null
        then
            echo "Internet found after wvdial, checking Openvpn"
            if ping -c 1 10.8.0.1 &> /dev/null
            then
                echo "OpenVPN connected already"
            else
                echo "OpenVPN restarting"
                systemctl restart openvpn-client@shootfor.service
            fi
        else
            echo "No Internet after wvdial, need to reboot"
            sleep 5
            /sbin/shutdown -r
        fi
    else
        echo "Missing GMSModem link, need to reboot"
        sleep 5
        /sbin/shutdown -r
    fi
fi
