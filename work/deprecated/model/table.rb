module Quarry

  class Table

    #
    def self.setup
      dbh = DBI.connect( "DBI:MySQL:databasename", "username", "password" )
            
    end

  end

end

