# Cyclid client

Note that the client is still in development. Some features are missing
entirely and the interface is liable to change at any moment.

## Installation

    $ gem install cyclid-client -s http://rubygems.cyclid.io

## Configuration

### Configuration file format

The configuration file is a simple YAML file with only four options.

1. server : **Required** : The hostname (and optionally the port number) of the
   cyclid server.
2. organization : **Required** : The organization name.
3. username : **Required** : The username that is associated with the
   organization.
4. secret : **Required** : The HMAC signing scret for the user.

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
