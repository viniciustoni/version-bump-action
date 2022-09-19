CURRENT_VERSION=$($DIR/get-version.sh)

if [ $BEFORE_VERSION == $CURRENT_VERSION ]; then
	echo "false"
else
	echo "true"
fi