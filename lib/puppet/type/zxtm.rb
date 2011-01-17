# This script enables puppet to manipulate traffic pools on a ZXTM Load Balancer
# (c) Matthew Macdonald-Wallace 2011
#
# Include the relevant libraries
require 'rubygems'
require 'zxtm-api'

module Puppet
	newtype(:zxtm) do
		@doc = "Manipulate ZXTM load balancers using Puppet"
		newparam(:name) do
			desc "The name of the resource"
			isnamevar
		end

		newparam(:zxtm) do
			desc "The hostname/ipaddress of the load balancer"
			defaultto ""
		end

		newparam(:poolname) do
			desc "The Pool to place the system into"
			defaultto ""
		end

		newparam(:serviceport) do
			desc "The port used for this service"
			defaultto ""
		end


		newproperty(:ensure) do
			desc "Whether the system is assigned to the correct pool or not"

			defaultto :insync

			def retrieve 
				p = PoolService.new(resource[:zxtm],'api','api')
				pool_name = resource[:poolname]
				if not p.list.include?(pool_name)
					err("Pool #{resource[:poolname]} not found... Creating it now...")
					p.create(pool_name)
				end
				if not p.list_nodes.include?(fact[:fqdn])
					err("Pool #{resource[:poolname]} does not contain the node #{fact[:fqdn]}... Adding it now...")
					p.add_node(resource[:poolname],"#{fact[:fqdn]}:#{resource[:serviceport]}")
					p.drain_node(resource[:poolname],"#{fact[:fqdn]}:#{resource[:serviceport]}")
				end
			end
		end
	end
end
