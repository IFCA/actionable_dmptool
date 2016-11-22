class Viaconcept < ActiveRecord::Base

  def has_children?
    return Viaconcept.count("taxonomy='#{self.taxonomy}' and parent = '#{self.identifier}}'")> 0
  end

  def children
    return Viaconcept.where("taxonomy='#{self.taxonomy}' and parent = '#{self.identifier}'")
  end

  def complete_route_text
    if(self.parent.nil?)
      return self.label
    else
      return to_root(self.parent) + ' -> ' + self.label
    end
  end


  def complete_route
    if(self.parent.nil?)
      return self.label
    else
      return to_root(self.parent) + ' -> <strong>' + self.label + '</strong>'
    end
  end

  def to_root (conceptId)
    if !conceptId.nil?
      concept = Viaconcept.where("taxonomy='#{self.taxonomy}' and identifier = '#{conceptId}'")[0]
      if(concept.parent.nil?)
        return concept.label
      else
        return to_root(concept.parent) + ' -> ' + concept.label
      end
    end
  end

end
