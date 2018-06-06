source ~/.fonts/i_all.sh

# alias quit="cd ~/xgdev && vagrant suspend && vagrant halt"
# alias start="cd ~/xgdev && vagrant up && vagrant ssh"

VM_NAME="xgdev"
function startvm() {
    xgdev_info=$(vboxmanage showvminfo $VM_NAME)
    if [ $(echo xgdev_info | grep -c "running (since") -gt 0 ]; then
	echo "VM already started... attempting to ssh in..."
	while ! ssh -Y user@172.16.10.2
	do
        	echo "Can't ssh into vm yet... waiting for 1 second."
        	sleep 1
    	done
    elif [ $(echo xgdev_info | grep -c "restoring (since") -gt 0 ]; then
	echo "VM starting up... waiting 3 seconds and trying again."
	sleep 3
	startvm
    elif [ $(echo xgdev_info | grep -c "saving (since") -gt 0 ]; then
	echo "VM currently saving... waiting 5 seconds and trying again."
	sleep 5
	startvm
    else
	echo "VM not started yet... starting vm."
	vboxmanage startvm $VM_NAME --type headless
	sleep 5
	startvm
    fi
}

function quitvm() {
    vboxmanage controlvm $VM_NAME savestate
}

function code {
    if [[ $# = 0 ]]
    then
        open -a "Visual Studio Code"
    else
        local argPath="$1"
        [[ $1 = /* ]] && argPath="$1" || argPath="$PWD/${1#./}"
        open -a "Visual Studio Code" "$argPath"
    fi
}

function resource {
	printf 'Refreshed bash configuration from %s\n' "$BASH_SOURCE"
	source $BASH_SOURCE
}

function save-start {
    (ruby ~/workspace/vm-backup/backup.rb &)
    cd ~/xgdev && vagrant up && vagrant ssh
}

base03="0;43;54"
base02="7;54;66"
base01="88;110;117"
base00="101;123;131"
base0="131;148;150"
base1="147;161;161"
base2="238;232;213"
base3="#253;246;227"
yellow="181;137;0"
orange="#203;75;22"
red="#220;50;47"
magenta="211;54;130"
violet="108;113;196"
blue="38;239;210"
cyan="42;161;152"
green="133;153;0"
endColor="\e[0m"
fg="38;2;"
bg="48;2;"
fgColor="\e[${fg}"
bgColor="\e[${bg}"

right=$i_ple_right_half_circle_thick
left=$i_ple_left_half_circle_thick

appleLogo="\[$fgColor$base1;$bg${base03}m\] $i_fa_apple \[$endColor\]"
linuxLogo="\[$fgColor$base1;$bg${base03}m\] $i_fa_linux \[$endColor\]"
sepOne="\[$fgColor$base03;$bg${base02}m\]$right\[$endColor\]"
directory="\[$fgColor$cyan;$bg${base02}m\]\w\[$endColor\]"
sepTwo="\[$fgColor$base02;$bg${base03}m\]$right\[$endColor\]"

sepOne_right="\[$fgColor$base2;$bg${base03}m\]$left\[$endColor\]"
sepThree="\[$fgColor$base2;$bg${base03}m\]$right\[$endColor\]"
timeStamp="\[$fgColor$base0;$bg${base2}m\]\@\[$endColor\]"

leftprompt="${appleLogo}${sepOne}${directory}${sepTwo}"
rightprompt="$timeStamp$sepThree"
export PS1="$leftprompt"
export PS2="${appleLogo}${sepOne}"
# export PS1="$leftprompt$rightprompt"
# export PS1="${appleLogo}${sepOne}${directory}${sepTwo}\[$(rightprompt;)\]"

function fix_window () {
	local wmctrl_output=$(/usr/local/bin/wmctrl -l)
	IFS=$'\n' array=($wmctrl_output); unset IFS

	for line in "${array[@]}"
	do
		local hex=${line%% *}
		echo "Fixing window with id: $hex"
		if [ "$5" = "true" ]; then
			eval "/usr/local/bin/wmctrl -ir $hex -e add,fullscreen"
		else
			eval "/usr/local/bin/wmctrl -ir $hex -e 0,$1,$2,$3,$4"
		fi
	done
}

function fix {
	fix_window 3843 0 3840 2114
}


