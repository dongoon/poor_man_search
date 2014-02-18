require 'active_record'
ActiveRecord::Base.establish_connection( :adapter => 'sqlite3', :database => ':memory:')

class CreateTestTables < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :email
    end

    create_table :comments do |t|
      t.integer :user_id
      t.integer :count
      t.string :said
    end
  end
end

ActiveRecord::Migration.verbose = false
CreateTestTables.up


class User < ActiveRecord::Base
  has_many :comments
end

class Comment < ActiveRecord::Base
  belongs_to :user
end
