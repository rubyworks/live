module Live

  #
  class Track < Sequel::Model(:tracks)

    #
    def self.popular(limit=10)
      order(:requires).limit(limit)
    end

    #
    def self.newest(limit=10)
      #order(:created).distinct(:owner, :name).limit(limit)
      filter(:archive=>false).order(:modified).limit(limit)
    end

    #
    def self.latest(limit=10)
      #.order(:modified).distinct(:owner, :name).limit(limit)
      filter(:archive=>false).order(:modified).limit(limit)
    end

    # Create track table.
    def self.create_table
      database.create_table(table_name) do |t|
        t.primary_key :id
        t.integer     :user_id                    #
        t.varchar     :owner                      # owner of script
        t.varchar     :name                       # name of script
        t.boolean     :watch,  :default => false  # keep tabs on this scripts changes?
        t.boolen      :star,   :defualt => false  # star 'cause I like it
        t.boolen      :flag,   :defualt => false  # warning flag!
      end
    end

    def self.drop_table
      database.drop_table(table_name)
    end

  end

end

