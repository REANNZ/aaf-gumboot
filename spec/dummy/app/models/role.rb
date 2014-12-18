class Role < ActiveRecord::Base
  has_many :api_subject_roles, class_name: 'API::APISubjectRole'
  has_many :api_subjects, through: :api_subject_roles
  has_many :permissions

  validates :name, presence: true
end
