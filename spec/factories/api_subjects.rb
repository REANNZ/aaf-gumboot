FactoryGirl.define do
  factory :api_subject, class: API::APISubject do
    x509_cn { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    email { Faker::Internet.email }
    enabled true

    trait :authorized do
      transient { permission '*' }

      after(:create) do |api_subject, attrs|
        role = create :role
        permission = create :permission, value: attrs.permission, role: role
        role.permissions << permission
        role.api_subjects << api_subject
      end
    end
  end
end
