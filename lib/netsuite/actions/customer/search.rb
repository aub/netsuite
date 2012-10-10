# TODO: Tests
# TODO: DBC
# TODO: Integrate with rest of gem
module NetSuite
	module Actions
		module Customer
			class Search
				def initialize(fields = {})
					@fields = fields
				end

				def self.call(fields)
					new(fields).call
				end

				def call
					response = NetSuite::Configuration.connection.request :search do
						soap.namespaces['xmlns:platformMsgs'] = "urn:messages_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com"
						soap.namespaces['xmlns:platformCore'] = "urn:core_#{NetSuite::Configuration.api_version}.platform.webservices.netsuite.com"
						soap.namespaces['xmlns:listRel'] = "urn:relationships_#{NetSuite::Configuration.api_version}.lists.webservices.netsuite.com"

						soap.header = NetSuite::Configuration.auth_header
						
						soap.body = request_body
					end
				end

				private

				def soap_type
        	self.class.to_s.split('::').last.lower_camelcase
      	end

	      def request_body
	        buffer = ''
        	
        	record_type = soap_type
        	
        	xml = Builder::XmlMarkup.new(target: buffer)
        	
        	xml.platformMsgs(:searchRecord, 'xsi:type' => 'listRel:CustomerSearch') do |customer_search|
        		@fields.each do |field_name, field_value|
        			# TODO: allow for different search operators
        			customer_search.listRel(field_name.to_sym, operator: 'contains') do |operator|
        				operator.platformCore :searchValue, field_value
        			end
        		end
        	end

        	buffer
	      end
			end
		end
	end
end