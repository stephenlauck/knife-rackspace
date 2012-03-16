#
# Author:: Adam Jacob (<adam@opscode.com>)
# Copyright:: Copyright (c) 2009 Opscode, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/knife/rackspace_base'
require 'chef/api_client'

class Chef
  class Knife
    class RackspaceServerDelete < Knife

      include Knife::RackspaceBase

      banner "knife rackspace server delete SERVER_ID [SERVER_ID] (options)"
      
      option :complete,
        :long => "--complete",
        :boolean => true,
        :description => "Delete server, node and client"

      def run
        @name_args.each do |instance_id|
          
          server = connection.servers.get(instance_id)

          msg("Instance ID", server.id.to_s)
          msg("Host ID", server.host_id)
          msg("Name", server.name)
          msg("Flavor", server.flavor.name)
          msg("Image", server.image.name)
          msg("Public DNS Name", server.addresses["public"][0])
          msg("Private IP Address", server.addresses["private"][0])

          puts "\n"
          confirm("Do you really want to delete this server") unless config[:complete]

          server.destroy

          ui.warn("Deleted server #{server.id} named #{server.name}")
          
          puts "\n"
          confirm("Delete client and node for #{server.name}?") unless config[:complete]
         
          node = Chef::Node.load(server.name)
          puts "deleting node #{node.name}"
          node.destroy
          ui.warn("Deleted node named #{node.name}")

          client = Chef::ApiClient.load(server.name)
          puts "deleting client #{client.name}"
          client.destroy
          ui.warn("Deleted client named #{client.name}")
          
        end
      end

      def msg(label, value)
        if value && !value.empty?
          puts "#{ui.color(label, :cyan)}: #{value}"
        end
      end
    end
  end
end
