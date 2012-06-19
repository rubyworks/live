require 'coderay'

module Live

  #
  class Script < Sequel::Model(:scripts)

    #
    def self.popular(limit=10)
      order(:downloads).limit(limit)
    end

    #
    def self.newest(limit=10)
      #order(:created).distinct(:owner, :name).limit(limit)
      filter(:archive=>nil).order(:modified).limit(limit)
    end

    #
    def self.latest(limit=10)
      #.order(:modified).distinct(:owner, :name).limit(limit)
      filter(:archive=>nil).order(:modified).limit(limit)
    end

    # Create the scripts table.
    def self.create_table
      database.create_table(table_name) do |t|
        t.primary_key :id
        t.varchar     :owner, :size=>50         # owner of script
        t.varchar     :name, :size=>50          # name of script
        t.integer     :version, :default=>1     # version number
        t.varchar     :description              # brief description
        t.text        :code                     # script's source code
        t.text        :test                     # unit test code
        t.integer     :rating                   # rating # TODO: keep?
        t.integer     :downloads                # number of times this script has been required/loaded (less cache)
        t.timestamp   :downloaded, :null=>true  # date and time of last require/load
        t.varchar     :modifier                 # last person to modify the script
        t.timestamp   :modified                 # date and time the script was last modified
        t.timestamp   :created                  # date and time the script was created
        t.integer     :copy                     # id of script from which this script was copied
        t.integer     :archive                  # id of the current script; NULL if this is the current script
      end
    end

    # Drop table from database.
    def self.drop_table
      database.drop_table(table_name)
    end

    # Script save creates a new record in the table, in order to keep a history.
    #--
    # TODO: If nothing has changed there is no need to create a new record.
    #
    # TODO: compressing +code+ and +test+ would save space, but what about searching?
    #++
    def save(bump=false)
      now = Time.now

      if exists?
        if bump
          # archive current version
          h = self.values.dup 
          h.delete(:id)
          history = self.class.new(h)
          history.archive = id
          history.save
        end
      else
        self.created = now
      end

      if bump
        self.version = version.to_i + 1
      end

      self.modified = now

      super()
    end

    #
    #def owner_name
    #  "#{owner}/#{name}"
    #end

    #
    def code_highlighted
      CodeRay.scan(code, :ruby).div
    end

    #
    def test_highlighted
      CodeRay.scan(test, :ruby).div
    end

    #
    def track(user_id)
      Track[:user_id=>user_id, :owner=>owner, :name=>name]
    end

  end

end

