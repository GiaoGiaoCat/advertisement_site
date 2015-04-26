class Developer < ActiveRecord::Base
  # extends ...................................................................
  # includes ..................................................................
  include UserRelationship
  # security (i.e. attr_accessible) ...........................................
  # relationships .............................................................
  # validations ...............................................................
  # callbacks .................................................................
  # scopes ....................................................................
  default_scope -> { where(role: 'developer') }
  # additional config ..................................................
  self.table_name = "users"
  encrypted_id key: 'm8ByZ1rMXiMVcpJT'
  # class methods .............................................................
  # public instance methods ...................................................
  # protected instance methods ................................................
  # private instance methods ..................................................
end