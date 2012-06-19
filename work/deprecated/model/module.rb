module Quarry

  #
  class Module
    include DataMapper::Resource

    #storage_names[:default] = 'frt' # equivalent to set_table_name in AR

    #
    property :id, Serial

    ##
    # Name of module/class. Must be fullname (eg. 'Fruit::Basket').
    property :name, String

    ##
    # Also known as +superclass+.
    # If +NULL+ then it is a Ruby module.
    property :parent, Module

    ##
    # Modules that are included in this module/class.
    # This happens before any other applications, but after extensions.
    has n, :inclusions, Module, :through => :inclusions

    ##
    # Modules that extend this module/class.
    # This happens before any other applications.
    has n, :extensions, Module, :through => :extensions

    ##
    # Collection of methods that make up the class/module.
    has n, :methods, Method

    ##
    # Dynamic code to run before any methods are defined.
    property :dynamic_before, Text

    ##
    # Dynamic code to run after all methods are defined.
    property :dynamic_after, Text

    ##
    # Which User has ultimate jurisdiction over this module.
    property :owner, User

    ##
    # Keep an audit trail of record edits.
    has n, :audit, Audit
  end

  #
  class Extension
    include DataMapper::Resource
    property   :id,     Serial
    belongs_to :module, Module
    belongs_to :extend, Module
  end

  #
  class Inclusion
    include DataMapper::Resource
    property   :id,      Serial
    belongs_to :module,  Module
    belongs_to :include, Module
  end

end

