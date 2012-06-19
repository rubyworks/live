module Quarry

  # Keep an audit trail of all record modifications.
  # better name?
  class Audit
    property   :user,     User
    property   :datetime, DateTime
    belongs_to :module
  end

end

