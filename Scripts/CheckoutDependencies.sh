#!/bin/bash
#
#  iOSKit
#
#  Checkout required open source libraries
#  Created by Yarik Smirnov on 1/23/12.
#  Copyright (c) 2012 e-Legion ltd. All rights reserved.
#

GIT=`which git`;
GIT_SERVER="ssh://git.e-legion.com/home/repository/git/";

LIB_DIR="${PROJECT_DIR}/Libraries"

DRAWING_KIT="Drawing Kit";

checkDependence () {
    
    if [ ! -d "${1}" ]; then  
        ${GIT} clone --progress ${GIT_SERVER}$2 "${1}" 
    fi
    
    return 0;
}


#================= MAIN ======================

cd ${LIB_DIR};

checkDependence "${DRAWING_KIT}" yariksmirnov 

exit 0;
