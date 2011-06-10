class CreateLeeches < ActiveRecord::Migration
  def self.up
    create_table :leeches do |t|
      t.string :query2
      t.string :forumchoice

      t.timestamps
    end
  end

  def self.down
    drop_table :leeches
  end
end
