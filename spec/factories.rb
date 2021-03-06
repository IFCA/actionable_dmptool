
FactoryGirl.define do  factory :taxonomy do
    name "MyString"
description "MyString"
  end
  factory :viaconcept do
    identifier "MyString"
label "MyString"
description "MyString"
parent "MyString"
taxonomy "MyString"
  end
 
  

  factory :user do
    association :institution
  end


  factory :authentication do
    #provider :shibboleth
    #sequence(:uid) { |n| "test_user#{n}" }

    factory :ldap do
      provider :ldap
    end

    association :user
  end

  factory :authorization do
    association :user
    association :role
  end


  factory :institution do

    factory :test_institution do
      id        1
      full_name "Test Institution"
    end
    factory :test_institution_child do
      id        30
      full_name "Test sub-inst01"
    end
  end



  factory :role do
    name "DMP Administrator"
  end




end







# FactoryGirl.define do  factory :taxonomy do


#   factory :user do
#     sequence(:email) { |n| "test_email#{n}@ucop.edu" }
#     sequence(:first_name) { |n| "First_Name#{n}" }
#     sequence(:last_name) { |n| "Last_Name#{n}" }

#     association :institution
#   end

#   factory :institution do
#     sequence(:full_name) { |n| "University of California - Campus#{n}" }
#     sequence(:nickname) { |n| "UC#{n}" }
#     desc "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur quis nisi metus, pulvinar pulvinar diam. Curabitur dignissim aliquet lectus in laoreet. Maecenas in commodo nunc. Quisque blandit auctor mollis. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Ut quis nulla ut libero malesuada aliquam porttitor nec erat. Etiam suscipit lectus et ligula varius dictum. Vestibulum venenatis lectus eu leo mattis a dapibus elit congue."
#     sequence(:contact_info) { |n| "Contact Person #{n}" }
#     sequence(:contact_email) { |n| "contactemail#{n}@uc.edu" }
#     sequence(:url) { |n| "http://moreinformation#{n}.edu" }
#     sequence(:url_text) { |n| "More Information Page #{n}" }

#     factory :shibb do
#       sequence(:shib_entity_id) { |n| "urn:mace:incommon:uc#{n}.edu" }
#       sequence(:shib_domain) { |n| "uc#{n}.edu" }
#     end
#   end

#   factory :plan do
#     sequence(:name) { |n| "Data Management Plan #{n}" }
#     solicitation_identifier "2138219"
#     submission_deadline Time.now + 2.weeks
#     visibility :public

#     association :requirements_template
#   end

#   factory :published_plan do
#     sequence(:file_name) { |n| "file_name_#{n}.pdf" }
#     visibility :public

#     association :plan
#   end

#   factory :comment do
#     visibility :owner
#     value "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam porta risus nec est vehicula id ornare felis scelerisque. Aliquam erat."

#     association :user
#     association :plan

#     factory :reviewer do
#       visibility :reviewer
#     end
#   end

#   factory :response do
#     value "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nam porta risus nec est vehicula id ornare felis scelerisque. Aliquam erat."

#     association :plan
#     association :requirement
#     association :label
#   end

#   factory :label do
#     desc "MB"
#     group "data-size"
#   end

#   factory :authentication do
#     provider :shibboleth
#     sequence(:uid) { |n| "email#{n}@ucop.edu" }

#     factory :ldap do
#       provider :ldap
#     end

#     association :user
#   end

#   factory :authorization do
#     group 1

#     association :user
#     association :role
#   end

#   factory :resource_template do
#     name "Lorem Ipsum"
#     active false
#     review_type :no_review
#     widget_url "mywidget.com"

#     factory :active_true do
#       active true
#     end

#     factory :resource_review_type_formal do
#       review_type :formal_review
#     end

#     factory :resource_review_type_informal do
#       review_type :informal_review
#     end

#     association :requirements_template
#     association :institution
#   end

#   factory :resource do
#     resource_type :actionable_url
#     value "actionableurl.com"
#     label "This is a useful URL."

#     factory :expository_guidance do
#       resource_type :expository_guidance
#       value 'This is the text to guide the user.'
#       label 'Expository Guidance'
#     end

#     factory :example_response do
#       resource_type :example_response
#       value 'This is how you should respond to the question.'
#       label 'This is an example response.'
#     end

#     factory :suggested_response do
#       resource_type :suggested_response
#       value 'This is a suggested response.'
#       label 'This is the suggested response.'
#     end

#     association :resource_template
#     association :requirement
#   end

#   factory :requirements_template do
#     name 'Requirement Template Name'
#     active false
#     start_date Time.now
#     end_date Time.now + 2.weeks
#     visibility :public
#     parent_id nil
#     review_type :no_review

#     factory :institutional do
#       visibility :institutional
#     end

#     factory :active do
#       active true
#     end

#     factory :review_type_formal do
#       review_type :formal_review
#     end

#     factory :review_type_informal do
#       review_type :informal_review
#     end

#     association :institution
#   end

#   factory :requirement do
#     order 1
#     ancestry "1"
#     text_brief "Lorem Ipsum"
#     text_full "Lorem Ipsum Lrem Ipsum Lorem Ipsum"
#     requirement_type :text
#     obligation :mandatory
#     default "Lorem Ipsum Lrem Ipsum Lorem Ipsum"

#     factory :numeric do
#       requirement_type :numeric
#     end

#     factory :date do
#       requirement_type :date
#     end

#     factory :enum do
#       requirement_type :enum
#     end

#     factory :mandatory_applicable do
#       obligation :mandatory_applicable
#     end

#     factory :optional do
#       obligation :optional
#     end

#     factory :recommended do
#       obligation :recommended
#     end

#     association :requirements_template
#   end

#   factory :enumeration do
#     value "Lorem Ipsum"

#     association :requirement
#   end

#   factory :tag do
#     tag "Lorem Ipsum"

#     association :requirements_template
#   end

#   factory :additonal_information do
#     url "myurl.com"
#     label "Lorem Ipsum"

#     association :requirements_template
#   end

#   factory :sample_plan do
#     url "myurl.com"
#     label "Lorem Ipsum"

#     association :requirements_template
#   end

#   factory :role do
#     name "dmp_administrator"
#   end
# end