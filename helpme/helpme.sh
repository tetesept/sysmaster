#!/bin/bash
############################
#Sysmaster				   #
############################

#Hilfe
#aufruf der Hilfe Dateien

helpme()
{
	helpmaster=`dialog --colors --cancel-label "Exit" --backtitle "System Master Script" --title "Chose a Theme" --menu "\Zu\ZbMove using [UP] [DOWN], [Enter] to select\Zn" 0 0 0\
	Miscellaneous "General Things"\
    Management "Tell me more about the Script Funktions"\
    Back "Back to Mastermen" \
    3>&1 1>&2 2>&3`
    case $? in
            2)
                return 1
            ;;
            1)
                return 1
            ;;
    esac
    case $helpmaster in
    	Miscellaneous)
			dialog --colors --backtitle "System Master Script" --title "Miscellaneous Help" --exit-label "OK" --textbox $miscellaneoushelpme 0 0
		;;
		Management)
			dialog --colors --backtitle "System Master Script" --title "System Help" --exit-label "OK" --textbox $systemhelpme 0 0
		;;
		Back)
			return 1
		;;
	esac
	return 1
}
