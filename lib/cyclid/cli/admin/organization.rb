module Cyclid
  module Cli
    # 'admin organization' sub-commands
    class AdminOrganization < Thor
      desc 'list', 'List all of the organizations'
      def list
        orgs = client.org_list
        orgs.each do |org|
          puts org
        end
      rescue StandardError => ex
        abort "Failed to retrieve list of organizations: #{ex}"
      end

      desc 'show NAME', 'Show details of the organization NAME'
      def show(name)
        org = client.org_get(name)

        # Convert the public key to PEM
        der_key = Base64.decode64(org['public_key'])
        public_key = OpenSSL::PKey::RSA.new(der_key)

        # Pretty print the organization details
        puts 'Name: '.colorize(:cyan) + org['name']
        puts 'Owner Email: '.colorize(:cyan) + org['owner_email']
        puts 'Public Key: '.colorize(:cyan) + public_key.to_pem
        puts 'Members:'.colorize(:cyan)
        if org['users'].any?
          org['users'].each do |user|
            puts "\t#{user}"
          end
        else
          puts "\tNone"
        end
      rescue StandardError => ex
        abort "Failed to get organization: #{ex}"
      end

      desc 'create NAME OWNER-EMAIL', 'Create a new organization NAME'
      long_desc <<-LONGDESC
        Create an organization NAME with the owner email address EMAIL.

        The --admin option adds a user as the initial organization administrator.
      LONGDESC
      option :admin, aliases: '-a'
      def create(name, email)
        client.org_add(name, email)

        if options[:admin]
          # Add the user to the organization and create the appropriate admin
          # permissions for them.
          client.org_modify(name,
                            members: options[:admin])

          perms = { 'admin' => true, 'write' => true, 'read' => true }
          client.org_user_permissions(name,
                                      options[:admin],
                                      perms)
        end
      rescue StandardError => ex
        abort "Failed to create new organization: #{ex}"
      end

      desc 'modify NAME', 'Modify the organization NAME'
      long_desc <<-LONGDESC
        Modify the organization NAME.

        The --email option sets the owners email address.

        The --members options sets the list of organization members.

        *WARNING* --members will overwrite the existing list of members, so use with care!
      LONGDESC
      option :email, aliases: '-e'
      option :members, aliases: '-m', type: :array
      def modify(name)
        client.org_modify(name,
                          owner_email: options[:email],
                          members: options[:members])
      rescue StandardError => ex
        abort "Failed to modify organization: #{ex}"
      end

      desc 'delete NAME', 'Delete the organization NAME'
      long_desc <<-LONGDESC
        Delete the organization NAME from the server.

        The --force option will delete the organization without asking for confirmation.
      LONGDESC
      option :force, aliases: '-f', type: :boolean
      def delete(name)
        if options[:force]
          delete = true
        else
          print "Delete organization #{name}: are you sure? (Y/n): ".colorize(:red)
          delete = STDIN.getc.chr.casecmp('y') == 0
        end
        abort unless delete

        begin
          client.org_delete(name)
        rescue StandardError => ex
          abort "Failed to delete organization: #{ex}"
        end
      end
    end
  end
end
