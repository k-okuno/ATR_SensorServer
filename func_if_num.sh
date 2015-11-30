
#############################
# Function to check if arg is numeric.
# Usage:
# > ./if_num <an arg>
# Return:
# 0 : when <an arg> is Numeric
# 1 : when <an arg> is NOT Numeric
#############################
function if_num()
{
    expr "${1}" + 1 >/dev/null 2>&1
    if [ $? -lt 2 ]
    then
	#echo "Numeric"
	return 0
    else
	#echo "not Numeric"	
	return 1	
    fi
}
