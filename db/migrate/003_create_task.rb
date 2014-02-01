class CreateTask < ActiveRecord::Migration
  def up
	  create_table :tasks do |t|
      t.string :name
		  t.string :status
		  t.integer :total_time
  	end
  end

  def down
	drop_table :tasks
  end
end


