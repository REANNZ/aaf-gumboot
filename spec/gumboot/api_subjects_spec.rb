require 'spec_helper'

require 'gumboot/shared_examples/api_subjects'

RSpec.describe API::APISubject, type: :model do
  include_examples 'API Subjects'
end
