#!/bin/bash


if [[ -z $CONFIG_PATH ]] then
	CONFIG_PATH="/etc/simpleci.yaml"
fi

readconfig() {
	$REPO=$(niet repo_link $CONFIG_PATH)
}


init() {

}


func=$1

case func in
	"Init")
		


esac
