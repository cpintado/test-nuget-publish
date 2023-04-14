# test-nuget-publish

[![Run tests](https://github.com/cpintado/test-nuget-publish/actions/workflows/run-tests.yml/badge.svg)](https://github.com/cpintado/test-nuget-publish/actions/workflows/run-tests.yml)

## Table of Contents

- [What does this tool do?](#what-does-this-tool-do)
- [Requirements](#requirements)
- [Setup](#setup)
- [How to use](#how-to-use)
- [Environment variables](#environment-variables)

## What does this tool do?

This is a docker image that when run publishes an empty package to the GitHub Packages NuGet registry or to a GitHub Enterprise Server instance of your choice. In this way you can test if your GitHub Packages setup is properly configured without delving into the details of the package manager.

It accepts varios parameters, such as the package name and version, token to use for authentication, etc.

## Requirements

A Linux/Mac machine with Docker installed.

## Setup

Authenticate to the GitHub Container Registry as described in the [Documentation](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-to-the-container-registry). For example, you can go to the settings of your GitHub account, [create a personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token) with the `read:packages` scope, and then do the following:

```
export CR_PAT=YOUR_TOKEN
echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
```

Once you are authenticated, you can install the tool like this:

```
docker pull ghcr.io/cpintado/test-nuget-publish:v1.0.0
```

## How to use

The downloaded image can then be run using the `docker run` command. Parameters are passed to the image via environment variables.

For example, to publish a Nuget package to the `cpintado-org` organization in `github.com`, authenticating as the `cpintado` user with the <PAT> token, it can be done like this:

```
docker run -e USER=cpintado -e TOKEN=<PAT> -e NAMESPACE='cpintado-org' ghcr.io/cpintado/test-nuget-publish:v1.0.0
```

It can also be done by pre-defining the values of the environment variables, like this:


```
export USER=cpintado
export NAMESPACE='cpintado-org'
export TOKEN=<PAT>
docker run -e USER -e TOKEN -e NAMESPACE ghcr.io/cpintado/test-nuget-publish:v1.0.0
```

Both of the above examples will publish to the `cpintado-org` organization a package with the `cpintado-org-test-package` name and with version number `1.0.0`.

This is the simplest example but you can use more environment variables to suit your use case.

## Environment variables

This is a reference of the environment variables that can be passed as arguments to the docker image.

| **Env variable** | **Required** | **Default value** | **Notes** |
|------------------|--------------|-------------------|-----------|
| USER | yes | N/A | Username of your personal account, as documented in [authenticating with a personal access token](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-nuget-registry#authenticating-with-a-personal-access-token) |
| NAMESPACE | yes | N/A | Organization or user to which the package will be published |
| TOKEN | yes | N/A | Personal access token with the necessary scopes (`write:packages`) |
| MODE | no | publish | If set to `publish` it tries to publish the package, if set to `download` it tries to download a package with the same name instead |
| PACKAGE_ID | no | ${NAMESPACE}-test-package | Name of the package to be published/downloaded
| PACKAGE_VERSION | no | 1.0.0 | Version of the package to be published/downloaded
| REPOSITORY_URL | no | N/A | A repository to which to associate the package to. This is not required in `github.com`, but please note that as of GitHub Enterprise Server 3.8 this is still a requirement for GitHub Enterprise Server. |
| GHES_HOSTNAME | no | N/A | Fully qualified domain name of a GitHub Enterprise Server instance to which the package has to be published/downloaded. |
| SUBDOMAIN_ISOLATION | no | true | In case a GitHub Enterprise Server instance has been specified, a value of `true` indicates the instance has [subdomain isolation](https://docs.github.com/en/enterprise-server@3.8/admin/configuration/configuring-network-settings/enabling-subdomain-isolation) enabled. A value of `false` indicates that subdomain isolation is not enabled for the instance. This is used to determine the correct URL of the registry. 


