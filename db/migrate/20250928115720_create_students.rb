class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.string :name
      t.integer :reading
      t.integer :writing
      t.integer :listening
      t.integer :speaking
      t.integer :total_score
      t.float :percentage

      t.timestamps
    end
  end
end
