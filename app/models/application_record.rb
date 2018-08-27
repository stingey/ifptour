class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  attr_accessor :displayed_errors
end
