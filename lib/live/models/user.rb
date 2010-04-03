require 'digest/md5'
require 'digest/sha1'

#
class User < Sequel::Model(:users)

  #attr_accessor :password

  #def after_create
  #  self.passcode = encrypt(password)
  #  @new = false
  #  save
  #end

  #
  def password=(pass)
    self.passcode = encrypt(pass)
  end

  def email=(address)
    self.salt ||= Digest::SHA1.hexdigest("--#{Time.now.to_f}--#{address}--")
    super(address)
  end

  #
  def authenticated?(password)
    passcode == encrypt(password)
  end

  #
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  # Gravatar URL
  def gravatar
    hash = Digest::MD5.hexdigest(email)
    "http://www.gravatar.com/avatar/#{hash}"
  end

  #
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  #
  def self.authenticate(username, password)
    return nil unless username && password
    if username =~ /\@/
      user = User[:email => username]
    else
      user = User[:username => username]
    end
    if user
      return user unless password
      return user if user.authenticated?(password)
    end
    return nil
  end

  # Create the 'user' table.
  def self.create_table
    database.create_table(table_name) do |t|
      t.primary_key :id
      t.varchar     :username, :size => 50
      t.varchar     :passcode  # encryped password
      t.text        :salt
      t.varchar     :name, :size => 50
      t.varchar     :email
      t.varchar     :website
      t.boolean     :confirmed, :default=>false
      t.timestamp   :modified
    end
  end

  #
  def self.drop_table
    database.drop_table(table_name)
  end

end

