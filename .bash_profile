source ~/.fonts/i_all.sh
source ~/.git-prompt.sh

# alias quit="cd ~/xgdev && vagrant suspend && vagrant halt"
# alias start="cd ~/xgdev && vagrant up && vagrant ssh"

VM_NAME="xgdev"
function startvm() {
    xgdev_info=$(vboxmanage showvminfo $VM_NAME)
    if [[ "$(echo $xgdev_info | grep -c 'running (since')" -gt "0" ]]; then
	echo "VM already started... attempting to ssh in..."
	while ! ssh -Y user@172.16.10.2
	do
        	echo "Can't ssh into vm yet... waiting for 1 second."
        	sleep 1
    	done
    elif [[ "$(echo $xgdev_info | grep -c 'restoring (since')" -gt "0" ]]; then
	echo "VM starting up... waiting 3 seconds and trying again."
	sleep 3
	startvm
    elif [[ "$(echo $xgdev_info | grep -c 'saving (since')" -gt "0" ]]; then
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

function fix_window () {
	local wmctrl_output=$(/usr/local/bin/wmctrl -l)
	IFS=$'\n' array=($wmctrl_output); unset IFS

	for line in "${array[@]}"
	do
		local hex=${line%% *}
		echo "Fixing window with id: $hex"
		if [ "$5" == "true" ]; then
			eval "/usr/local/bin/wmctrl -ir $hex -e add,fullscreen"
		else
			eval "/usr/local/bin/wmctrl -ir $hex -e 0,$1,$2,$3,$4"
		fi
	done
}

function fix {
	fix_window 3843 0 3840 2114
}

function eclipse() {
	if [[ "$(vboxmanage showvminfo $VM_NAME | grep -c 'running (since')" -gt "0" ]]; then
		if [[ $(ssh user@172.16.10.2 "pgrep eclipse") ]]; then
			fix
		else
			ssh -fY user@172.16.10.2 "rm -f ~/workspace/.metadata/.lock && nohup ~/launch-eclipse.sh &" 
			while [ "$(fix)" == "" ]; do sleep 1; done
		fi
	else
		echo "VM not started... Start VM and try again."
	fi		
}


base03="0;43;54"        # darkest blueish
base02="7;54;66"        # lighter blueish
base01="88;110;117"     # dark grey
base00="101;123;131"    # lighter grey
base0="131;148;150"     # lighter still
base1="147;161;161"     # light grey at this point
base2="238;232;213"     # light yellow... sandy
base3="#253;246;227"    # lighter yellow
yellow="181;137;0"
orange="#203;75;22"
red="#220;50;47"
magenta="211;54;130"
violet="108;113;196"
blue="38;239;210"
cyan="42;161;152"
green="133;153;0"
fg="38;2;"
bg="48;2;"

color_open='\001'
color_close='\002'

fgColor="\033[${fg}"
bgColor="\033[${bg}"
endColor="${color_open}\033[0m${color_close}"
Save='\033[s'
Rest='\033[u'

logo_color="${color_open}${fgColor}${base1};${bg}${base03}m${color_close}"
directory_color="${color_open}${fgColor}${cyan};${bg}${base02}m${color_close}"
timeStamp_color="${color_open}${fgColor}${base0};${bg}${base2}m${color_close}"
sepOne_color="${color_open}${fgColor}${base03};${bg}${base02}m${color_close}"
sepTwo_color="${color_open}${fgColor}${base02};${bg}${base03}m${color_close}"
sepThree_color="${color_open}${fgColor}${base2};${bg}${base03}m${color_close}"

right=$i_ple_right_half_circle_thick    # replace with delimiter between segments on left half of prompt
left=$i_ple_left_half_circle_thick      # replace with delimiter between segments on right half of prompt.

git_logo=$i_dev_github_badge
linux_logo=$i_fa_linux
apple_logo=$i_fa_apple

appleLogo="${logo_color} ${apple_logo} ${endColor}"
linuxLogo="${logo_color} ${linux_logo} ${endColor}"
gitLogo="${logo_color} ${git_logo} ${endColor}"

sepOne="${sepOne_color}${right}${endColor}"
sepTwo="${sepTwo_color}${right}${endColor}"
sepThree="${sepThree_color}${right}${endColor}"

sepOne_right="${sepOne_color}${left}${endColor}"
sepTwo_right="${sepTwo_color}${left}${endColor}"
sepThree_right="${sepThree_color}${left}${endColor}"

directory="${directory_color}\w${endColor}"
timeStamp="${timeStamp_color}\@${endColor}"

parse_git_branch() {
        __git_ps1 | sed 's/[()]//g'
}

git_branch() {
        local branch=$(parse_git_branch)
        if [ ${#branch} != 0 ]; then
                printf "%s" "${directory_color}$(parse_git_branch)${endColor}"
        fi
}

print_right() {
        local branch=$(git_branch)
        local length=$(echo -n $branch | stripped_length)
        if [ $length != 0 ]; then
                printf "%s" "${sepTwo_right}${branch}${sepOne_right}${gitLogo}"
        fi
}

print_git_left() {
        local branch=$(git_branch)
        local length=$(echo -n $branch | stripped_length)
        if [ $length != 0 ]; then
                echo -ne "${gitLogo}${sepOne}$(git_branch)${sepTwo}"
        fi
}

print_left() {
        printf "%s" "${linuxLogo}${sepOne}${directory}${sepTwo}"
}

print_prompt() {
        local left_prompt=$(print_left)
        local right_prompt=$(print_right)

        #local left_length=$(echo $left_prompt | stripped_length)
        #local right_length=$(echo $right_prompt | stripped_length)

        local right_length=$(( $(parse_git_branch | wc -m)  ))

        local prompt=""
        if [ $right_length > 0 ]; then
                right_length=$(( $right_length + ${#right} + ${#right} + ${#git_logo} ))
                prompt="${prompt}\001\033[$(( ${COLUMNS} - ${right_length} - 1 ))C\002${right_prompt}\001\033[${COLUMNS}D\002"
        fi

        printf "%s" "${prompt}${left_prompt}"
}

print_prompt_boring() {
        echo -ne "${linuxLogo}${sepOne}${directory}${sepTwo}$(print_git_left)"
}

forward_columns() {
        printf "%s" "\001\033[${COLUMNS}C\002"
}

backward_right() {
        printf "%s" "\001\033[$(right_length)D\002"
}

strip() {
        sed -E 's/(\\001.*\\002)\s*(.*)(\\001.*\\002)/\2/'
}

stripped_length() {
        strip | wc -m
}

right_length() {
        print_right | stripped_length
}

left_length() {
        print_left | stripped_length
}


export PS1="${appleLogo}${sepOne}${directory}${sepTwo}\$(print_git_left)"
export PS2="${appleLogo}${sepOne}"
