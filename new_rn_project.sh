#!/bin/bash

scriptName="${0##*/}"
DEFAULT_NAME="my_project"
DEFAULT_DIRECTORY="~/Documents/Development.nosync/"
name=$DEFAULT_NAME
directory=$DEFAULT_DIRECTORY

function printUsage() {
    cat <<EOF

Synopsis
    $scriptName [-n name] [-d directory]
    Initialize React Native project.

    -n name
        Name of project.
        Default value: $DEFAULT_NAME.
    
    -d directory
        Enclosing directory where project will be located.
        Default value: $DEFAULT_DIRECTORY


Created by Michael McRoskey
EOF
}

function createGitIgnore() {
    cd $directory
    cat <<EOF >.gitignore
node_modules/**/*
.expo/*
npm-debug.*
EOF
}

function createREADME() {
    cd $directory
    cat <<EOF >README.md
#$name
------

EOF
}

function createFolders() {
    cd $directory
    mkdir src
    cd src
    for SUB_DIR in api assets components constants navigation screens reducers styles utils
	do
        mkdir $SUB_DIR
    done
    cd ..
}

function printFinalSteps() {
    cat <<EOF

Now please:
1. add repo to GitHub Desktop
2. publish repo to GitHub
3. add Finder shortcut to repo to sidebar

EOF
}

function addAlias() {
    cat <<EOT >> ~/.bash_profile
alias $1='cd ${directory}${name}'
EOT
source ~/.bash_profile
}

function configESLint() {
    cat <<EOT >> .eslintrc.js
module.exports = {
	extends: 'airbnb',
	parser: 'babel-eslint',
	"env": {
		"jest": true,
		"react-native/react-native": true
	},
	"plugins": [
		"react",
		"react-native"
	],
	rules: {
    'react/forbid-prop-types': 'off',
    'react/jsx-filename-extension': [1, { extensions: ['.js', '.jsx'] }],
	'react/jsx-max-props-per-line': [1, { 'when': 'multiline' }],
	'no-console': 0,
	'camelcase': 0,
	},
};
EOT
}

function configReactotron() {
    cat <<EOT >> ReactotronConfig.js
import Reactotron from 'reactotron-react-native'

Reactotron
  .configure({
    name: "$name"
  })
  .useReactNative({
    asyncStorage: false, // there are more options to the async storage.
    networking: { // optionally, you can turn it off with false.
      ignoreUrls: /symbolicate/
    },
    editor: false, // there are more options to editor
    errors: { veto: (stackFrame) => false }, // or turn it off with false
    overlay: false, // just turning off overlay
  })
  .connect();
EOT

cat <<EOT >> App.js
import './ReactotronConfig'
EOT
}

function addDevDependencies() {
    for DEV_DEP in babel-eslint eslint eslint-config-airbnb eslint-plugin-react eslint-plugin-jsx-a11y eslint-plugin-import reactotron-react-native
	do
        npm i --save-dev $DEV_DEP
    done
}

function addDependencies() {
    for DEP in react-navigation moment prop-types
	do
        npm i --save $DEP
    done
}

# Options.
while getopts ":n:d:" option; do
    case "$option" in
        n) name=$OPTARG ;;
        d) directory=$OPTARG ;;
        *) printUsage; exit 1 ;;
    esac
done
shift $((OPTIND - 1))

echo "Starting script"
read -p "Enter shortcut name: " aliasName
(
    cd $directory

    echo "Updating Expo"
    npm i -g exp
    
    echo "Creating blank $name in Expo"
    exp init $name -t blank
    cd $name

    echo "Adding git"
    git init

    echo "Creating .gitignore"
    createGitIgnore

    echo "Creating file structure"
    createFolders

    echo "Adding README"
    createREADME

    echo "Adding alias"
    addAlias $aliasName

    echo "Installing React Native"
    npm i

    echo "Installing recommended dev dependencies"
    addDevDependencies

    echo "Installing recommended dependencies"
    addDependencies

    echo "Adding ESLint and Reactotron config files"
    configESLint
    configReactotron

    echo "Complete!"
    printFinalSteps

    # Final tasks for user:
    open -R $directory
    open -a GitHub\ Desktop
    
) 2> /dev/null &&
# ^^ ignore stderr

exec "$@"