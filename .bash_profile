source ~/.fonts/i_all.sh

# alias quit="cd ~/xgdev && vagrant suspend && vagrant halt"
# alias start="cd ~/xgdev && vagrant up && vagrant ssh"

function startvm() {
    status=$(vboxmanage showvminfo "xgdev" | grep -c "running (since")
    if [ $status = 1 ]; then
        echo "VM already started... attempting to ssh in..."
    else
        echo "VM not started yet... starting vm."
        vboxmanage startvm xgdev --type headless
        echo "Attempting to ssh into vm..."
    fi

    while ! ssh user@172.16.10.2
    do 
        echo "..."
    done
}

function quitvm() {
    vboxmanage controlvm xgdev savestate
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
