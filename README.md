# Cyclid client

Note that the client is still in development. Some features are missing
entirely and the interface is liable to change at any moment.

## Contents

* [Installation](#installation)
* [Configuration](#configuration)
  * [Configuration file format](#configuration-file-format)
     * [Example](#example)
  * [Switching between configurations](#switching-between-configurations)
  * [Specifying a configuration file](#specifying-a-configuration-file)
* [Commands](#commands)
  * [User commands](#user-commands)
     * [user show](#user-show)
     * [user passwd](#user-passwd)
     * [user modify](#user-modify)
  * [Organization commands](#organization-commands)
     * [organization list](#organization-list)
     * [organization show](#organization-show)
     * [organization use](#organization-use)
     * [organization modify](#organization-modify)
     * [organization member](#organization-member)
         * [organization member list](#organization-member-list)
         * [organization member show](#organization-member-show)
         * [organization member add](#organization-member-add)
         * [organization member permission](#organization-member-permission)
         * [organization member remove](#organization-member-remove)
     * [organization config](#organization-config)
         * [organization config show](#organization-config-show)
         * [organization config edit](#organization-config-edit)
  * [Job commands](#job-commands)
     * [job show](#job-show)
     * [job status](#job-status)
     * [job log](#job-log)
     * [job submit](#job-submit)
  * [Stage commands](#stage-commands)
     * [stage list](#stage-list)
     * [stage show](#stage-show)
     * [stage create](#stage-create)
     * [stage edit](#stage-edit)
  * [Secret commands](#secret-commands)
     * [secret encrypt](#secret-encrypt)
  * [Admin commands](#admin-commands)
     * [admin organization list](#admin-organization-list)
     * [admin organization show](#admin-organization-show)
     * [admin organization create](#admin-organization-create)
     * [admin organization modify](#admin-organization-modify)
     * [admin organization delete](#admin-organization-delete)
     * [admin user list](#admin-user-list)
     * [admin user show](#admin-user-show)
     * [admin user create](#admin-user-create)
     * [admin user passwd](#admin-user-passwd)
     * [admin user modify](#admin-user-modify)
     * [admin user delete](#admin-user-delete)

Created by [gh-md-toc](https://github.com/ekalinin/github-markdown-toc.go)

## Installation

    $ gem install cyclid-client -s http://rubygems.cyclid.io

## Configuration

### Configuration file format

The configuration file is a simple YAML file with only four options.

| Option|Required?|Description|
|---|---|---|
|server|Required|The hostname (and optionally the port number) of the cyclid server.|
|organization|Required|The organization name.|
|username|Required|The username that is associated with the organization.|
|secret|Required|The HMAC signing secret for the user.|

#### Example

    server: cyclid.example.com
    organization: my_organization
    username: user
    secret: b1fc42ef648b4407f30dc77f328dbb86b03121fb15aba256497ef97ec9a3cd02

### Switching between configurations

The client uses configuration files under `$HOME/.cyclid` You can have
multiple configuration files and switch between the with the
`organization use` command.

For example, of your user belongs to two organizations, you can have one
configuration file for each organization E.g.

    $HOME/.cyclid/organization_one
    $HOME/.cyclid/organization_two

and then use the command `cyclid organization use organization_one` to select
it as the current configuration.

To find the list of available configurations, use the `organization list`
command.

### Specifying a configuration file

You can use the `--config` or `-c` option to specify the path to a configuration file to use instead of the current configuration that has been set with the `organization use` command.

## Commands

Cyclid commands are grouped under the following categories:

|Group|Description|
|---|---|
|user|Manage your current user|
|organization|Manage your current organization|
|job|Manage and submit jobs|
|stage|Manage stage definitions|
|secret|Create secrets|
|admin|Administrator commands|

### User commands

#### user show

Display your current user details.

	$ cyclid user show
	Username: bob
	Email: bob@example.com
	Organizations
		example

#### user passwd

Change your current users password. The user password is only used for HTTP Basic authentication.

	$ cyclid user passwd
	Password: <enter new password>
	Confirm password: <re-enter new password>

#### user modify

Change your current users email address, HMAC secret and/or password. You can pass the following options:

|Option|Short option|Description|
|---|---|---|
|--email|-e|Change your email address|
|--secret|-s|Change your HMAC secret|
|--password|-p|Change your email address|

Unlike the interactive `user passwd` command you can use `user modify` and pass your new password on the command line.

Your HMAC secret should ideally be a suitably long (at least 256 bit) and random string, which you should keep secure in your Cyclid configuration file. After changing your HMAC secret you will need to update your configuration file with the new secret before you can run any other Cyclid commands.

	# Change your email
	$ cyclid user modify --email robert@example.com
	# Change your HMAC secret
	$ cyclid user modify --secret b072d8b51cec2755145c401b9249a60ebd89b4704eeebc5b6805ba682d7fac53

### Organization commands

#### organization list

Lists all of the available organization configurations on your local machine.

	$ cyclid org list
	admins
		Server: http://example.com
		Organization: admins
		Username: admin
	example
		Server: http://example.com
		Organization: example
		Username: bob

#### organization show

Display the details of your currently selected organization, including the list of organization members and its public key.

	$ cyclid org show
	Name: example
	Owner Email: bob@example.com
	Public Key: -----BEGIN PUBLIC KEY-----
	MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8P8CMCfYLqMfAGq/pWyV
	r92w8TMo3A5Irf1iZsFko42WGgIdOAnDuguODUFIzWmyrKm1WL0+V403j914gCRL
	8Zi+To3qbQtLaD4etiP/p3Z6qEHt77rn67kRxKjpcyiHkwOtQxMO5VCXlYCvEnDz
	0Rn2cq9VutrjrZcOjNCk7AkUtTZ3arkntYPaNBtPDpQz1x3dGdumSgVBUx1dcaqE
	khLVc1SB1mqPNcIKoqIQF5oNGBdNWA6oBxk5CNj1GfpXayawixjgvq+tkJo3mDbu
	F6UzJ4UGzbpC3EYqCkEByNOXv4J2aYaOjChFUiHn1XcSUVZHkrzFcb47Pif1wshi
	lwIDAQAB
	-----END PUBLIC KEY-----
	Members:
		bob
		lucy
		dave
		leslie

#### organization use

Select an organization configuration to use by default. Pass a name of an organization from `organization list` to select it as your current configuration. If you do not pass a new organization name, the name of the currently selected organization is shown.

	# Show the currently selected organization
	$ cyclid organization use
	example
	# Select the 'admins' organization
	$ cyclid organization use admins

#### organization modify

Modify the current organization. This command can only be used by organization admins.

You can pass the following options:

|Option|Short option|Description|
|---|---|---|
|--email|-e|Change the owner email address|

	# Change the organization owner email address
	$ cyclid organization modify --email lucy@example.com

#### organization member

The `organization member` command has a series of sub-commands which are used to manage users which belong to the organization.

##### organization member list

List all of the users who are members of the current organization.

	$ cyclid organization member list
	bob
	lucy
	dave
	leslie

##### organization member show

Display the user details of an organization member, including the user permissions.

	$ cyclid organization member show bob
	Username: bob
	Email: bob@example.com
	Permissions
		Admin: false
		Write: true
		Read: true

##### organization member add

Add user(s) to the current organization. You must pass at least one username.

Users are added without any permissions set. You can use the `organization member permission` command to modify the user permissions after they have been added to the organization.

	# Add a single user, 'bob', to the organization
	$ cyclid organization member add bob
	# Add multiple users, 'bob' and 'lucy', to the organization
	$ cyclid organization member add bob lucy

##### organization member permission

Modify a users permissions for the organization. You must pass the username and the level of access you want the user to have. This can be one of:

* admin
* write
* read
* none

The 'admin' permission implies 'write', and the 'write' permission implies 'read'.

With 'none' the user remains an organization member but can not interact with it. See the `organization member remove` command if you want to actually remove a user from the organization.

	# Give the user 'bob' read-only access to the organization
	$ cyclid organization member permission bob read
	# Give the user 'lucy' admin permissions for the organization
	$ cyclid organization member permission lucy admin

##### organization member remove

Remove user(s) from the current organization. You must pass at least one username. By default the `organization member remove` command will ask you to confirm the removal first; you can over-ride this with the `--force/-f` option to force removal without confirmation.

|Option|Short option|Description|
|---|---|---|
|--force|-f|Do not ask for confirmation before removing the user|

	# Remove the user 'bob' from the organization without asking for confirmation
	$ cyclid organization member remove bob --force

#### organization config

The `organization config` command has a series of sub-commands which are used to get and set plugin configurations for your organization.

##### organization config show

Show the current organization specific configuration for a plugin. You must specify both the plugin type, and the plugin name.

	# Show the current configuration for the Github API plugin
	$ cyclid organization config show api github
	Repository OAuth tokens
		None
	Github HMAC signing secret: Not set

##### organization config edit

Modify the organization specific configuration for a plugin. You must specify both the plugin type, and the plugin name.

The `config edit` command expects the `$EDITOR` environment variable to be set to the path of a valid text editor that it can start.

	$ cyclid organization config edit api github
	# The Github plugin configuration is loaded in your text editor

### Job commands

#### job show

Show the details of a job. You must pass a valid job ID.

	$ cyclid job show 7
	Job: 7
	Name: test_job
	Version: 1.0.0
	Started: Thu Apr 21 16:40:57 2016
	Ended: Thu Apr 21 16:41:04 2016
	Status: Succeeded

#### job status

Show the status of a job. You must pass a valid job ID.

	$ cyclid job status 7
	Status: Succeeded

#### job log

Show the log from a job. You must pass a valid job ID.

	$ cylid job log 7
	2016-04-21 16:40:57 +0100 : Obtaining build host...
	2016-04-21 16:41:47 +0100 : Preparing build host...
	===============================================================================
	2016-04-21 16:41:47 +0100 : Job started. Context: {"job_id"=>7, "job_name"=>"test_job", "job_version"=>"1.0.0", "organization"=>"example", "os"=>"ubuntu_trusty", "name"=>"mist-3c04c6134a3f776cbe8e91e396d4dace", "host"=>"192.168.1.247", "username"=>"build", "workspace"=>"/home/build", "password"=>nil, "key"=>"~/.ssh/id_rsa_build", "server"=>"build01", "distro"=>"ubuntu", "release"=>"trusty"}
	-------------------------------------------------------------------------------
	2016-04-21 16:41:47 +0100 : Running stage example v1.0.0
	...

#### job submit

Submit a Cyclid job file to be run. The `job submit` command expects to be passed a path to a valid Cyclid job file in either JSON or YAML format.

The `job submit` command will attempt to automatically detect the format of the job file. You can use the `--json/-j` or `--yaml/-y` options to over-ride the format detection.

The job ID for the job will be shown once the job has been submitted. You can then check the status of the job with the `job status`, `job show` and `job log` commands.

|Option|Short option|Description|
|---|---|---|
|--json|-j|Parse the file as JSON|
|--yaml|-y|Parse the file as YAML|

	$ cyclid job submit job.yml
	Job: 8

### Stage commands

#### stage list

List all of the stages, and each version of each stage, that are defined for the organization.

	$ cyclid stage list
	example v0.0.1
	example v0.0.2
	example v0.1.0
	success v1.0.0
	success v1.0.1
	failure v1.0.0
	
#### stage show

Show the details of a stage.

	$ cyclid stage show example
	Name: example
	Version: 0.0.1
	Steps
			Action: command
			Cmd: echo
			Args: ["'hello", "world'"]
	Name: example
	Version: 0.0.2
	Steps
			Action: command
			Cmd: echo
			Args: ["'hello", "world'"]
	Name: example
	Version: 0.1.0
	Steps
			Action: command
			Cmd: echo
			Args: ["'Hello", "universe'"]

#### stage create

Create a new stage, or a new version of a stage, from a stage definition in a file. The `stage create` command expects to be passed a path to a valid Cyclid stage definition file in either JSON or YAML format.

The `stage create` command will attempt to automatically detect the format of the stage file. You can use the `--json/-j` or `--yaml/-y` options to over-ride the format detection.

|Option|Short option|Description|
|---|---|---|
|--json|-j|Parse the file as JSON|
|--yaml|-y|Parse the file as YAML|

	$ cyclid stage create stage.yml

#### stage edit

Edit a stage definition that exists on the server. Note that individual versions of a stage are immutable; once a version of a stage has been created it can not be deleted or modified. However, you can create a new version.

If you attempt to create a stage with the same name & version of an existing stage, the command will fail.

The `stage edit` command expects the `$EDITOR` environment variable to be set to the path of a valid text editor that it can start.

	$ cyclid stage edit example
	# The 'example' stage definition is loaded in your text editor

### Secret commands

#### secret encrypt

Encrypts a string with the organizations public key. You can then add the encrypted secret to the `secrets` section of a Cyclid job definition.

	$ cyclid secret encrypt
	Secret: <Enter the secret to be encrypted>
	Secret: uzegcZfXPuj4KNo+EpP928cgPW37gMDhdKw9OoCE0YXKWWtJ+kJIHzLyOGrF7p6dDJ3cWNZhEDADINJqsYMoaSbSAdT5Gx+lAo7BWOP+y20j9ECLyktfmhBi7mdxg66URcEe/VnD9JN9OObwGTaycb1XryZWeU/Hfr45Y/HObUnFhE+W+IHbAswMBO9bs3DogF672DFXkTtt+b0XW6ttyHGIqUqxoo8zFBEaDQlxa5oaW3iXSmcA+rrfolPO6gl9wI4PxH2kbxDeLoSo4Jolle3Oqv5SwcNOUChMHWsdJwrLDKvz995SvPJdVNkfsIAz1dDw8NYo0SroxIdC/3XzBQ==

### Admin commands

Admin commands are used for server wide configuration, and are only available to server admins I.e. users who are members of the 'admins' group.

Admin commands are grouped under the following categories:

|Group|Description|
|---|---|
|organization|Manage organizations|
|user|Manage users|

##### admin organization list

List all of the organizations on the server.

	$ cyclid admin organization list
	admins
	example
	initech
	
##### admin organization show

Show the details of an organization, including the owner email address, the list of organization members and its public key.

	$ cyclid admin organization show example
	Name: example
	Owner Email: bob@example.com
	Public Key: -----BEGIN PUBLIC KEY-----
	MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA8P8CMCfYLqMfAGq/pWyV
	r92w8TMo3A5Irf1iZsFko42WGgIdOAnDuguODUFIzWmyrKm1WL0+V403j914gCRL
	8Zi+To3qbQtLaD4etiP/p3Z6qEHt77rn67kRxKjpcyiHkwOtQxMO5VCXlYCvEnDz
	0Rn2cq9VutrjrZcOjNCk7AkUtTZ3arkntYPaNBtPDpQz1x3dGdumSgVBUx1dcaqE
	khLVc1SB1mqPNcIKoqIQF5oNGBdNWA6oBxk5CNj1GfpXayawixjgvq+tkJo3mDbu
	F6UzJ4UGzbpC3EYqCkEByNOXv4J2aYaOjChFUiHn1XcSUVZHkrzFcb47Pif1wshi
	lwIDAQAB
	-----END PUBLIC KEY-----
	Members:
		bob
		lucy
		dave
		leslie

##### admin organization create

Create a new organization. You must supply the name of the new organization, and the organization owners email. You may also optionally add a user as the initial organization admin using the `--admin/-a` option.

|Option|Short option|Description|
|---|---|---|
|--admin|-a|Username of the initial organization admin|

	# Create the 'example' organization with no initial admin
	$ cyclid admin organization create example bob@example.com
	# Create the 'initech' organization with the user 'lucy' as the initial admin
	$ cyclid admin organization create initech lucy@example.com --admin lucy

##### admin organization modify

Change an organizations owner email address or organization membership. You can pass the following options:

|Option|Short option|Description|
|---|---|---|
|--email|-e|Change the organization owner email address|
|--members|-m|Set a list of organization members|

**Note:** The `--members/-m` option will *overwrite* the complete list of members for an organization. Organization admins can use the `organization member` collection of commands to add & remove individual members in an organization.

	# Change the owner email for the 'example' organization
	$ cyclid admin organization modify example --email robert@example.com

##### admin organization delete

Delete an organization. By default the `organization delete` command will ask you to confirm the deletion first; you can over-ride this with the `--force/-f` option to force deletion without confirmation.

**Note:** Deleting organizations is not currently supported by the API and this command will always fail.

|Option|Short option|Description|
|---|---|---|
|--force|-f|Do not ask for confirmation before deleting the organization|

	# Delete the 'initech' organization
	$ cyclid admin organization delete initech

##### admin user list

List all of the users on the server.

	$ cyclid admin user list
	admin
	bob
	lucy
	dave
	leslie

##### admin user show

Show the details of a user, including their email address and the list organizations they belong to.

	$ cyclid admin user show bob
	Username: bob
	Email: bob@example.com
	Organizations:
		example

##### admin user create

Create a new user. You must supply the username of the new user, and the users email address.

You may also optionally set the users HTTP Basic password with the `--password/-p` option, or set their HMAC secret with the `--secret/-s` option. You must at least set their password *or* their HMAC secret for the user to be able to log in to the server.

The users HMAC secret should ideally be a suitably long (at least 256 bit) and random string, which the user should keep secure in their Cyclid configuration file.

|Option|Short option|Description|
|---|---|---|
|--password|-p|The new users initial HTTP Basic password|
|--secret|-s|The new users HMAC signing secret|

	# Create the user 'bob' with an initial HMAC secret
	$ cyclid admin user create bob bob@example.com -s b072d8b51cec2755145c401b9249a60ebd89b4704eeebc5b6805ba682d7fac53

##### admin user passwd

Change a users password. The user password is only used for HTTP Basic authentication.

	# Change the password for the user 'bob'
	$ cyclid admin user passwd bob
	Password: <enter new password>
	Confirm password: <re-enter new password>

##### admin user modify

Change a users email address, HMAC secret and/or password. You can pass the following options:

|Option|Short option|Description|
|---|---|---|
|--email|-e|Change the users email address|
|--secret|-s|Change the users HMAC secret|
|--password|-p|Change the users email address|

Unlike the interactive `user passwd` command you can use `user modify` and pass the users new password on the command line.

Your HMAC secret should ideally be a suitably long (at least 256 bit) and random string, which the user should keep secure in their Cyclid configuration file. After changing a users HMAC secret they will need to update their configuration file with the new secret before they can run any other Cyclid commands.

	# Change the email address for the user 'bob'
	$ cyclid admin user modify bob --email robert@example.com
	# Change the HMAC secret for the user 'lucy'
	$ cyclid admin user modify lucy --secret b072d8b51cec2755145c401b9249a60ebd89b4704eeebc5b6805ba682d7fac53

##### admin user delete

Delete a user. By default the `user delete` command will ask you to confirm the deletion first; you can over-ride this with the `--force/-f` option to force deletion without confirmation.

|Option|Short option|Description|
|---|---|---|
|--force|-f|Do not ask for confirmation before deleting the user|

	# Delete the user 'bob' without asking for confirmation
	$ cyclid admin user delete bob --force