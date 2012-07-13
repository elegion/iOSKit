#!/bin/bash
#
#  iOSKit
#
#  Checkout required open source libraries
#  Created by Yarik Smirnov on 1/23/12.
#  Copyright (c) 2012 e-Legion ltd. All rights reserved.
#

GIT=`which git`;
GIT_SERVER=`git remote show origin | grep Fetch | awk '{print $3}' | sed 's!iOSKit.git!!g'`;

LIB_DIR="${PROJECT_DIR}/Libraries"

DRAWING_KIT="DrawingKit";

checkDependence () {
	
	if [ ! -d "${1}" ]; then
	   
		if [ ${GIT_SERVER} = "*github.com*"]; then
			${GIT} clone --progress ${GIT_SERVER}$1".git"
		else 
			${GIT} clone --progress "git://github.com/yariksmirnov/"$1".git" 
		fi
	fi
    
    return 0;
}


#================= MAIN ======================

cd ${LIB_DIR};

checkDependence "${DRAWING_KIT}" 

exit 0;
