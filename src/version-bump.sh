#!/bin/bash

# Directory of this script
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

#
# Takes a version number, and the mode to bump it, and increments/resets
# the proper components so that the result is placed in the variable
# `NEW_VERSION`.
#
# $1 = mode (major, minor, patch)
# $2 = version (x.y.z)
#
function bump {
    local mode="$1"
    local old="$2"
    local parts=(${old//./ })
    case "$1" in
    major)
        local bv=$((parts[0] + 1))
        NEW_VERSION="${bv}.0.0"
        ;;
    minor)
        local bv=$((parts[1] + 1))
        NEW_VERSION="${parts[0]}.${bv}.0"
        ;;
    patch)
        local bv=$((parts[2] + 1))
        NEW_VERSION="${parts[0]}.${parts[1]}.${bv}"
        ;;
    auto)
        if [ "${AUTO_HIGHER}" == "true" ] && [[ "${parts[2]}" == *"${AUTO_SPLITTER}${AUTO_SUFFIX}"* ]]; then
            local higher=(${parts[2]//${AUTO_SPLITTER}${AUTO_SUFFIX}/ })
            local bv=$((higher[1] + 1))
            NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 0))${AUTO_SPLITTER}${AUTO_SUFFIX}${bv}"
        elif [ "${AUTO_HIGHER}" == "false" ] && [[ "${parts[2]}" == *"${AUTO_SPLITTER}${AUTO_SUFFIX}"* ]]; then
            local higher=(${parts[2]//${AUTO_SPLITTER}${AUTO_SUFFIX}/ })
            local bv=$((higher[1] + 0))
            NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 0))${AUTO_SPLITTER}${AUTO_SUFFIX}${bv}"
        elif [ "${AUTO_HIGHER}" == "true" ]; then
            NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 0))${AUTO_SPLITTER}${AUTO_SUFFIX}0"
        else
            NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 0))${AUTO_SPLITTER}${AUTO_SUFFIX}"
        fi
        ;;
    esac
}

if [ "${COMMITTER}" = "BOT" ]; then
    # Usage for defined name and mail
    git config --global user.email $EMAIL
    git config --global user.name $NAME
else
    # Usage for last commit
    git config user.name "${GITHUB_ACTOR}"
    git config user.email "${GITHUB_ACTOR}@users.noreply.github.com"
fi

OLD_VERSION=$($DIR/get-version.sh)

BUMP_MODE="none"
NEW_VERSION="-"
if git log -1 | grep -q "#major"; then
    BUMP_MODE="major"
elif git log -1 | grep -q "#minor"; then
    BUMP_MODE="minor"
elif git log -1 | grep -q "#patch"; then
    BUMP_MODE="patch"
elif [[ "${AUTO}" == "true" ]]; then
    BUMP_MODE="auto"
fi

if [ "${REPO_BUILD}" = "GRADLE" ]; then
    BUILD_FILE=$GRADLEPATH/build.gradle
    TYPE=GROOVY
    if [ ! -f "$BUILD_FILE" ]; then
        BUILD_FILE=$GRADLEPATH/build.gradle.kts
        TYPE=KOTLIN
    fi
fi

if [[ "${BUMP_MODE}" == "none" ]]; then
    echo "No matching commit tags found."
    if [ "${REPO_BUILD}" = "MAVEN" ]; then
        echo "pom.xml at" $POMPATH "will remain at" $OLD_VERSION
    else
        echo "build.gradle at" $GRADLEPATH "will remain at" $OLD_VERSION
    fi

else
    echo $BUMP_MODE "version bump detected"
    bump $BUMP_MODE $OLD_VERSION
    REPO="https://$GITHUB_ACTOR:$TOKEN@github.com/$GITHUB_REPOSITORY.git"
    if [ "${REPO_BUILD}" = "MAVEN" ]; then
        echo "pom.xml at" $POMPATH "will be bumped from" $OLD_VERSION "to" $NEW_VERSION
        mvn -q versions:set -DnewVersion="${NEW_VERSION}"
        git add $POMPATH/pom.xml
        git commit -m "Bump pom.xml from $OLD_VERSION to $NEW_VERSION"
    else
        echo "build.gradle at " $GRADLEPATH " will be bumped from" $OLD_VERSION "to" $NEW_VERSION
        if [ "${TYPE}" == "GROOVY" ]; then
            sed -i "s/$OLD_VERSION/$NEW_VERSION/" $BUILD_FILE
        elif [ "${TYPE}" == "KOTLIN" ]; then
            sed -i "s/version = \"$OLD_VERSION\"/version = \"$NEW_VERSION\"/" $BUILD_FILE
        fi
        git add $BUILD_FILE
        git commit -m "Bump build.gradle from $OLD_VERSION to $NEW_VERSION"
    fi

    if [[ "${BUMP_MODE}" == "auto" ]] && [[ "${AUTO_RELEASE}" == "false" ]]; then
        echo "Doing no new tag for this bump because its disabled for auto mode"
        git push $REPO
    else
        git tag $NEW_VERSION
        git push $REPO --follow-tags
        git push $REPO --tags
        echo "Created a new tag for this bump"
    fi
fi
