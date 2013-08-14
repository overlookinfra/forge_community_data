class AddRepositoriesTable < ActiveRecord::Migration
  def up
    create_table :repositories do |t|
    	t.string :module_name
      t.string :repository_name
      t.string :repository_owner
    end
    
    add_column :pull_requests, :repo_id, :integer, { :null => false, :default => 0 }
    remove_column :pull_requests, :repository_name
    remove_column :pull_requests, :repository_owner
  end

  def down
    drop_table :repositories
    remove_column :pull_requests, :repo_id
    add_column :pull_requests, :repository_name, :string
    add_column :pull_requests, :repository_owner, :string
  end
end
