alias findfile=findTheFile

fileToFind=''
ignLibs=''
echoDirs=''
stop=false
echoIgnLibs=false

function findTheFile() {

    stop=false
    echoIgnLibs=false
    fileToFind="$1"
    startDir="$2"
    echoDirs="$3"
    ignLibs="$4" 

    if [ "$ignLibs" = "ignLib" ]; then
        ignLibs='yes'
    else
	echo 'Are you sure that you want to search Library files (Y/n)'
        read ignLibs
	if [[ $ignLibs == *"y"* ]] || [[ $ignLibs == *"Y"* ]]; then
		ignLibs='yes'
	else
		ignLibs='no'
        fi
    fi

    if [ "$echoDirs" = "wDirs" ]; then
        echoDirs='yes'
    fi

    cd "$startDir"

    YELLOW='\033[1;33m'
    echo -e ${YELLOW}searching. . .
    getDirs
    if [ $stop = false ]; then
        RED='\033[0;31m'
        echo -e ${RED}file not found
    fi
}

function getDirs() {
    if [ $stop = false ]; then
        found=false
        allFiles=($(ls -a)) 
        for i in ${allFiles[@]}; do
		 if [ "$i" = "$fileToFind" ]; then
                    GREEN='\033[0;32m'
                    echo -e ${GREEN}found: $(pwd)/$i
                    stop=true
                    found=true
                fi
        done
        
        if [ $found = false ]; then
            allDirs=()
            {
                allDirs=($(ls -a -d */))
            } &> /dev/null
            if [[ ${#allDirs} -gt 40 ]]; then
                echo Do you want to search $(pwd). "It might take a while (Y/n)"
                read response
                if [[ $response == *"y"* ]] || [[ $response == *"Y"* ]]; then
                    response='yes'
                else
                    response='no'
                fi
            fi
            if [ "$response" = "yes" ]; then
                for ((x=1; x<${#allDirs[@]}+1; x++))
                do
                    if [[ ${allDirs[$x]} != *"/"*  ]] && [[ "${allDirs[$x]}" != "!%%%%!" ]]; then	
                        place=0
                        while [ true  ]
                        do
                            if [[ ${allDirs[$(($x + $place))]} == *"/"* ]]; then
                                break
                            else	
                                place=$(($place + 1))
                            fi
                        done
                        for ((a=1; a<$place+1; a++))
                        do
                            allDirs[$x]=${allDirs[$x]}^${allDirs[$(($x+$a))]}
                        done
                        for ((a=1; a<$place+1; a++))
                        do
                            allDirs[$(($x+$a))]="!%%%%!"
                        done
                    fi
                done
            fi

            for i in ${allDirs[@]}
            do
                fail=false
                if [ $stop = false ] && [[ $i != "!%%%%!" ]]; then
                    if [[ "$echoDirs" == "yes" ]]; then
                        GREY='\033[0;37m'
                        echo -e ${GREY}$(pwd)
                    fi
                    dir="${i//^/ }"
                    {
                        if [ "$ignLibs" = "yes" ] && [ "$dir" = "Library/" ]; then
                            fail=true
                            echoIgnLibs=true
                        else
                            cd "$dir"
                        fi
                    } &>/dev/null || {
                        dir=' '$dir
                        {
                            cd "$dir"
                        } &>/dev/null || {
                            fail=true
                        }
                    }
                    if [ $fail = false ]; then
                        getDirs
                    else 
                        if [ $echoIgnLibs = true ]; then
                            YELLOW='\033[1;33m'
                            echo -e ${YELLOW}Ignoring Library. . .
                            sleep 1.5
                            echoIgnLibs=false
                        fi
                    fi
                fi
            done
            cd ../
        fi
    fi
}
