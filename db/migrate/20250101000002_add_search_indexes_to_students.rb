class AddSearchIndexesToStudents < ActiveRecord::Migration[8.0]
  def change
    # Add indexes for search performance (only if they don't exist)
    add_index :students, :name unless index_exists?(:students, :name)
    add_index :students, :total_score unless index_exists?(:students, :total_score)
    add_index :students, :percentage unless index_exists?(:students, :percentage)
    add_index :students, :created_at unless index_exists?(:students, :created_at)
    add_index :students, :user_id unless index_exists?(:students, :user_id)

    # Add indexes for individual skills
    add_index :students, :reading unless index_exists?(:students, :reading)
    add_index :students, :writing unless index_exists?(:students, :writing)
    add_index :students, :listening unless index_exists?(:students, :listening)
    add_index :students, :speaking unless index_exists?(:students, :speaking)

    # Add index for notes content search
    add_index :notes, :content unless index_exists?(:notes, :content)
  end
end # rubocop:disable Layout/TrailingEmptyLines