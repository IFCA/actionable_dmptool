module ResponsesHelper
	def requirement(requirement_id)
		@requirement = Requirement.find(requirement_id)
	end

	def get_concept_tree (taxonomy_name)
		roots = Viaconcept.where("taxonomy='#{taxonomy_name}' and parent is null")
		aux = Viaconcept.where("taxonomy='#{taxonomy_name}' ")
		parents = parent_map aux
		listAux = Array.new
		roots.each do |root|
			mapAux = Hash.new
			mapAux[:id]=root.identifier
			mapAux[:label]=root.label
			mapAux[:bdid] = root.id
			listAux.push mapAux
		end
		to_tree(listAux, parents)
	end

	def to_tree (list, parents)
		map = Array.new
		list.each do |root|
			id = root[:id]
			mapAux = Hash.new
			mapAux[:label]=root[:label]
			mapAux[:bdid] = root[:bdid]
			mapAux[:children] = to_tree(parents[id], parents) unless parents[id].nil?
			map.push mapAux
		end
		return map

	end

	def parent_map (list)
		map = Hash.new
		list.each do |element|
			if(map[element.parent].nil?)
				listAux = Array.new
			else
				listAux = map[element.parent]
			end
			mapAux = Hash.new
			mapAux[:id]=element.identifier
			mapAux[:label]=element.label
			mapAux[:bdid]=element.id
			listAux.push mapAux
			map[element.parent] = listAux
		end
		return map
	end
end
