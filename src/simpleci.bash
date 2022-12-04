#!/bin/bash


[[ -z $CONFIG_PATH ]] && CONFIG_PATH="/etc/simpleci/config.yaml"

readconfig() {
	REPO="$(niet repo_link $CONFIG_PATH)"
	HOOK_PASSWD="$(niet tg_bot.webhook_send_password $CONFIG_PATH)"
	TG="$(niet tg_hook $CONFIG_PATH)sendbase/$HOOK_PASSWD/"
	REPO_PATH=$(niet repo_path $CONFIG_PATH)
	REPO_BRANCH=$(niet branch $CONFIG_PATH)
}


send_to_tg() {
	echo -e $1
	curl $TG$(echo -e $1 | base64 -w 0) 1>/dev/null 2>/dev/null
}

weird_cat() {
	perl -p -e 's/\n/\\n/' $1
}

contains() {
	tmp=$1[@]
	arr=(${!tmp})

	# echo 1 = ${arr[@]} >&2
	# echo 2 = $2 >&2

	for x in ${arr[@]}; do 
		[[ $x == $2 ]] && return 0
	done
    return 1
}


docker_up() {
	service_name=$(pwd | sed "s#$REPO_PATH/##")
	
	send_to_tg "🌊 <code>docker-compose up -d </code> at <b>$service_name</b>"

	if docker-compose up -d 2>/tmp/errlog; then
		send_to_tg "🥦 service started successfully"
	else
		send_to_tg "🔥 <b>failed to do docker-compose up in $(pwd)\n\nError:</b>\n<code>$(weird_cat /tmp/errlog)</code>"
	fi
}

docker_rebuild() {
	service_name=$(pwd | sed "s#$REPO_PATH/##")
	
	send_to_tg "🪡 <code>docker-compose up -d --build</code> at <b>$service_name</b>"

	if docker-compose up -d --build 2>/tmp/errlog; then
		send_to_tg "🎉 service rebuilded successfully"
		return 0
	else
		send_to_tg "🔥 <b>failed to docker-compose up -d --build in $(pwd)\n\nError:</b>\n<code>$(weird_cat /tmp/errlog)</code>"
		return 1
	fi
}


find_services() {
	find $REPO_PATH -name 'docker-compose.*' | sed 's/docker-compose.*//'
}

init() {
	send_to_tg "😎 simpleci init"

	mkdir -p $REPO_PATH
	
	echo "git clone"

	git clone $REPO $REPO_PATH

	cd $REPO_PATH

	echo "docker-compose up -d on all services..."

	for service in $(find_services); do
		cd $service
		docker_up
	done
}

get_updated_services() {
	updated_files=$(git diff origin/$branch | grep '+++' | sed 's/+++ .//')

	updates_services=()

	for file in $updated_files; do
		file_sp=($(echo $file | sed 's/\///' | tr '/' ' '))

		len=${#file_sp[@]}
		for i in $(seq $len); do
			try_path="$(echo ${file_sp[@]:0:$(($len-$i+1))} | sed 's/ /\//g')/"

			if [[ -n $(find "$try_path" -name 'docker-compose.*' 2>/dev/null) ]]; then
				# echo contains "${updates_services[@]}" "$try_path" >&2
				contains updates_services $try_path || updates_services+=($try_path) && break
			fi
		done
	done

	echo ${updates_services[@]}
}


rebuild_services() {
	success=0

	for service in ${1}; do
		docker_dir=$(find $service -name 'docker-compose.*' | sed 's/docker-compose.*//')
		cd $docker_dir
		docker_rebuild $service || success=1

		cd $REPO_PATH
	done

	return $success
}

rollback() {
	commit_name=$(git log | grep commit | cut -d' ' -f2 | head -n 1)
	git tag "bad__$commit_name"

	send_to_tg "⏳ rolling back 1 commit, to $(git log HEAD~1 | grep commit | cut -d' ' -f2 | head -n 1)"

	git reset --hard HEAD~1 || send_to_tg "<b>пизда</b>"

	rebuild_services $1 || rollback $1
}

check() {
	cd $REPO_PATH
	branch=$REPO_BRANCH

	git remote update

	[[ -n $(git log origin $branch --format="%h %D" | head -n 1 | grep "bad__") ]] && return 0


	services=$(get_updated_services)

	echo services = ${services}

	[[ -z $services ]] && return 0

	send_to_tg "👀 found updated services: <b>$(echo ${services[@]} | sed 's#/ # #g' | sed 's#/$##')</b>"

	git pull

	rebuild_services "${services}" || rollback "${services}"
}


func=$1

readconfig
case $func in
	"init")
		init
		;;
	"check")
		check
		;;
	*)
		echo "viable options: init, check"
esac
