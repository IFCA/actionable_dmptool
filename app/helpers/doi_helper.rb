module DoiHelper

	def get_doi(plan)
		doi= plan.doi
		req = Net::HTTP::Get.new(DATACITE_CONFIG['post_ws'] + doi, initheader = {'Content-Type' =>'application/json'})
		req.basic_auth DATACITE_CONFIG['user'], DATACITE_CONFIG['pass']
		response = Net::HTTP.new(DATACITE_CONFIG['host'], DATACITE_CONFIG['port']).start {|http| http.request(req) }
		return response.body
	end

	def get_metadata(plan)
		doi= plan.doi
		req = Net::HTTP::Get.new(DATACITE_CONFIG['metadata_ws'] + doi, initheader = {'Content-Type' =>'application/json'})
		req.basic_auth DATACITE_CONFIG['user'], DATACITE_CONFIG['pass']
		response = Net::HTTP.new(DATACITE_CONFIG['host'], DATACITE_CONFIG['port']).start {|http| http.request(req) }
		return response.body
	end


	def create_doi(plan)
		plan_id = plan.id
		req = Net::HTTP::Post.new(DATACITE_CONFIG['post_ws'] , initheader = {'Content-Type' =>'application/json'})
		req.basic_auth DATACITE_CONFIG['user'], DATACITE_CONFIG['pass']
		url = plan_url(plan, :format => "pdf")
		doi_id = "#{DATACITE_CONFIG['institution_prefix']}/#{plan_id}"
		data = "doi=#{doi_id}\nurl=#{url}"
		req.body = data
		response = Net::HTTP.new(DATACITE_CONFIG['host'], DATACITE_CONFIG['port']).start {|http| http.request(req) }
		return doi_id
	end

	def create_metadata(plan, coowners)
		req = Net::HTTP::Post.new(DATACITE_CONFIG['metadata_ws'] , initheader = {'Content-Type' =>'application/xml'})
		req.basic_auth DATACITE_CONFIG['user'], DATACITE_CONFIG['pass']
		req.body = get_metadata_xml(plan, coowners)
		response = Net::HTTP.new(DATACITE_CONFIG['host'], DATACITE_CONFIG['port']).start {|http| http.request(req) }
		puts "Response #{response.code} #{response.message}:
          #{response.body}"
	end

	def get_metadata_xml(plan, coowners)
		builder = Nokogiri::XML::Builder.new do |xml|
			xml.resource(:xmlns => 'http://datacite.org/schema/kernel-2.2',
									 'xmlns:xsi'=> 'http://www.w3.org/2001/XMLSchema-instance',
									 'xsi:schemaLocation' => 'http://datacite.org/schema/kernel-2.2 http://schema.datacite.org/meta/kernel-2.2/metadata.xsd') {
				xml.identifier(:identifierType => 'DOI'){
					xml.text plan.doi
				}
				xml.creators {
					xml.creator{
						xml.creatorName plan.owner.full_name
					}
				}
				xml.titles {
					xml.title plan.name
				}
				xml.publisher 'Lifewatch'
				xml.publicationYear plan.created_at.to_date.strftime("%Y")
				#xml.subjects {
				#	xml.subject 'Asunto de Prueba'
				#	xml.subject(:subjectScheme =>'DDC'){xml.text 'Geology, hydrology, meteorology'}
				#}
				unless coowners.nil?
					xml.contributors {
					coowners.each do |coowner|
						xml.contributor(:contributorType => 'RelatedPerson') {
							xml.contributorName coowner.full_name
						}
					end
					}
				end
				xml.dates {
					xml.date(:dateType => 'Created') {xml.text plan.created}
					xml.date(:dateType => 'Updated') {xml.text plan.modified}
				}
				xml.language 'eng'
				xml.resourceType(:resourceTypeGeneral => 'Software'){xml.text 'Data Manager Plan'}
				unless plan.solicitation_identifier.nil?
				xml.alternateIdentifiers {
					xml.alternateIdentifier(:alternateIdentifierType => 'Solicitation Identifier'){xml.text plan.solicitation_identifier}
				}
				end
				xml.relatedIdentifiers {
					xml.relatedIdentifier(:relatedIdentifierType => 'DOI', :relationType => 'IsCitedBy'){xml.text plan.doi}
					xml.relatedIdentifier(:relatedIdentifierType => 'URN', :relationType => 'Cites'){xml.text plan_url(plan, :format => "pdf")}
				}
				#xml.sizes {
				#	xml.size '21717 kb'
				#	xml.size '100 pages'
				#}
				#xml.formats {
				#	xml.format 'text/plain'
				#}
				xml.version '1.0'
				#xml.rights 'Open Database License'
				#xml.descriptions {
				#	xml.description(:descriptionType => 'Other'){xml.text 'Descripcion loloo'}
				#}
			}
		end
		return builder.to_xml
	end

end
