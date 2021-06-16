CURRENT_VERSION=$($DIR/get-version.sh)

if [ $BEFORE_VERSION = $CURRENT_VERSION ]
        then
                print 'false'
        else
                print 'true'