class CreateLog < ActiveRecord::Migration
  def up
	create_table :logs do |t|
  		t.string :start_time
		  t.string :end_time
      t.integer :task_time
		  t.references :task
  	end
  end

  def down
	drop_table :logs
  end
end

