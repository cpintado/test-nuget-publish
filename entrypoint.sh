#!/bin/bash

function configure_authentication() {

    # configure nuget source
    #
    if [ -n "$GHES_HOSTNAME" ]; then
	if [ "$SUBDOMAIN_ISOLATION" = "false" ]; then
	    URL="https://${GHES_HOSTNAME}/_registry/nuget/${NAMESPACE}/index.json"
	else
	    URL="https://nuget.${GHES_HOSTNAME}/${NAMESPACE}/index.json"
	fi
    else
	URL="https://nuget.pkg.github.com/${NAMESPACE}/index.json"
    fi	
    		
    dotnet new nugetconfig
    dotnet nuget add source --username $USER --password $TOKEN --store-password-in-clear-text --name github $URL --configfile nuget.config
}

function publish_nuget_package() {

    # create new project
    dotnet new classlib

    # package the project and generate the nupkg file with the package id and version
    if [ -n "$REPOSITORY_URL" ]; then
    	dotnet pack --configuration Release --output /output -p:PackageVersion=$PACKAGE_VERSION -p:PackageId=$PACKAGE_ID -p:RepositoryUrl=$REPOSITORY_URL
    else
	dotnet pack --configuration Release --output /output -p:PackageVersion=$PACKAGE_VERSION -p:PackageId=$PACKAGE_ID
    fi

    # publish package
    dotnet nuget push /output/*.nupkg --source github --api-key $TOKEN
}

function download_nuget_package() {

    # create new project
    dotnet new console

    # add package as dependency
    dotnet add package $PACKAGE_ID --version $PACKAGE_VERSION --no-restore

    dotnet restore

}

function validate_parameters() {

if [ -z "$MODE" ]; then
    echo "MODE not set. Using default value 'publish'"
    MODE="publish"
fi

if [[ ! "$MODE" =~ ^(publish|download)$ ]]; then
    echo "MODE must be either 'publish' or 'download'"
    exit 1
fi

if [[ ! $USER =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid value for USER or USER not specified"
    exit 1
fi

if [[ ! $TOKEN =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "Invalid value for TOKEN or TOKEN not specified"
    exit 1
fi

if [[ ! $NAMESPACE =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid value for NAMESPACE or NAMESPACE not specified"
    exit 1
fi

if [ -z "$PACKAGE_ID" ]; then
    echo "Package_ID not set. Using ${NAMESPACE}-dummy-package as default"
    PACKAGE_ID="${NAMESPACE}-dummy-package"
fi

if [[ ! $PACKAGE_ID =~ ^[a-z0-9-]+$ ]]; then
    echo "Invalid value for PACKAGE_ID"
    exit 1
fi

if [ -z "$PACKAGE_VERSION" ]; then
    echo "PACKAGE_VERSION not set. Using 1.0.0 as default"
    PACKAGE_VERSION="1.0.0"
fi

if [[ ! $PACKAGE_VERSION =~ ^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(-((0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*)(\.(0|[1-9][0-9]*|[0-9]*[a-zA-Z-][0-9a-zA-Z-]*))*))?(\+([0-9a-zA-Z-]+(\.[0-9a-zA-Z-]+)*))?$ ]]; then
    echo "Invalid value for PACKAGE_VERSION or PACKAGE_VERSION not specified"
    exit 1
fi

if [ -n "$REPOSITORY_URL" ]; then
    if [[ ! $REPOSITORY_URL =~ ^https://[a-zA-Z0-9./?=_-]*$ ]]; then
	echo "Invalid value for REPOSITORY_URL"
	exit 1
    fi
fi

if [ -n "$GHES_HOSTNAME" ]; then
    if [[ ! $GHES_HOSTNAME =~ ^[a-z0-9-]+[a-z0-9.-]*$ ]]; then
	echo "Invalid value for GHES_HOSTNAME"
	exit 1
    fi
fi

if [ -z "$REPOSITORY_URL" ]; then
    if [ -n "$GHES_HOSTNAME" ]; then
	echo "Warning: REPOSITORY_URL not set. Setting a repository URL is required to publish a NuGet package in GHES"
    fi
fi

}

function main() {

    validate_parameters

    configure_authentication

    if [ "$MODE" = "publish" ]; then
	publish_nuget_package
    elif [ "$MODE" = "download" ]; then
	download_nuget_package
    fi
}

main

