#!/usr/bin/env bash


#	Dependencies
#		SingularityCE
#		Bubblewrap
#		Tini
#		Abduco




















report() {
	cat <<< "[0m"
	grep "$@" <<< "    $@"
	return
}


here() {
	local here="$(dirname "$(realpath ${BASH_SOURCE[0]})")"
	
	local i="$1"
	while [[ "$i" -gt 0 ]]; do
		if [[ "$i" -gt 100 ]]; then
			i=100
		fi
		((--i))
		local here="$(dirname "$here")"
	done
	echo "$here" > /dev/stdout
}
echo "local here is $(here)"

tartarus() {
	echo [094m
	local verbose='/dev/null'; [[ $@ == *" --verbose "* ]] && verbose='/dev/stdout'
	echo Verbose > $verbose

	if [[ $@ == *" --version "* ]]; then
		echo "    Tartarus v. 0.0.1"
		return
	fi

	local parameters
	append() {
		for i in "${list[@]}"; do
			i=" $i "
			parameters+=$i" "
		done
		unset list
	}

rm -fr /tmp/tartarus/etc/$USER
mkdir -p /tmp/tartarus/etc/$USER
echo "$USER:x:$(id -u):$(id -g):$USER User:$HOME:/bin/bash" > /tmp/tartarus/etc/$USER/passwd
echo "$USER:x:$(id -g):" > /tmp/tartarus/etc/$USER/group
# chmod 444 /tmp/tartarus/etc/$USER/passwd


local bind='--ro-bind'		# Use overlay instead of bind
for a in "$@"; do 
	[[ $a == -w ]] && local bind='--bind'
done

#>>>	Defaults
	local list=(
		--new-session
		# --setenv USER root
		# --setenv HOME /root
		--setenv USER "$USER"
		--setenv HOME "$HOME"
		--die-with-parent
		--cap-drop ALL
		# --uid 0 --gid 0
		--uid "$(id -u)" --gid "$(id -g)"
		# --unshare-all
		# --unshare-user
		# --unshare-pid
		# --unshare-net
		# --unshare-ipc
		--tmpfs 						/
		--tmpfs							/tmp
		--dir /root
		--ro-bind						/usr	/usr
		# $bind 					/etc/passwd	/etc/passwd
		# $bind						/etc/group	/etc/group
		--ro-bind /tmp/tartarus/etc/$USER/passwd /etc/passwd
		--ro-bind /tmp/tartarus/etc/$USER/group	/etc/group
		$bind							/bin	/bin
		$bind							/sys	/sys
		$bind							$HOME	$HOME
		--ro-bind						/lib	/lib
		--ro-bind						/lib64	/lib64
		--bind 				     /tmp/.X11-unix /tmp/.X11-unix
		--bind 		 /run/user/"$(id -u)"/pulse /run/user/"$(id -u)"/pulse
		--proc							/proc
		--dev							/dev
	);	append






#>>>	Unshare Flags as Arguments
	local list=(
		ipc
		net
		user
	)

	for i in "${list[@]}"; do
		for Arg in "$@"; do
			if [[ "$i" == "$Arg" ]]; then
				list=(${list[@]/$i})
			fi
		done
	done
	for i in "${list[@]}"; do
		parameters+=" $(echo "--unshare-$i") "
	done





#>>>	Custom Mount (passed as argument)
	for item in $@; do
		if [[ $item == %*% ]]; then
			echo "Creating mount point ${item:1:-1}" > $verbose
			local list=(
				--tmpfs			/"${item:1:-1}"/
			);	append
		fi
	done







	
	[[ $@ == *" --verbose "* ]] && cat <<-EOF
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
echo "bwrap $parameters /bin/bash"
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	EOF
	# parameters+="--ro-bind /home/spirit/Syncosa/.VSCodium/Tartarus/dvtm /dvtm"
	parameters+="--ro-bind /home/spirit/Syncosa/.VSCodium/Tartarus/runtime.sh /runtime.sh"
	parameters+=" -- /usr/bin/tini -s -- "



	local base="/tmp/overlay"
	mkdir -p "$base"/{lower,upper,work,merged}
	cat <<< "sin" > "$base"/lower/test.txt

	
	bwrap $parameters bash -c '
	export PS1="${USER}@tartarus:~$ "
	#######################################
	####  environment logic goes here  ####
	#######################################


	#######################################
	## uncomment to override source lock ##
	k=(####################################

	# ~/.bashrc
	# ~/.profile
	# ~/.bash_login
	# ~/.bash_profile
	# /etc/.bashrc
	# /etc/.profile

	#######################################
	); for i in $k; do source $i; done ####
	#######################################
	abduco -c tartarus bash'
	echo [0m
}







# unshare --user --mount --map-root-user -- bash -c "
#   mount -t overlay overlay -o lowerdir=$base/lower,upperdir=$base/upper,workdir=$base/work $base/merged
#   echo 'new' > $base/merged/new.txt
#   ls -l $base/merged
# "





















main() {
	tartarus $@
}


if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
	main $@
fi






#>>>
	# Canvas



















































































