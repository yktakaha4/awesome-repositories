class ChangeImageUrlOfRepositories < ActiveRecord::Migration[5.0]
  def up
    change_column :repositories, :image_url, :text, default: nil
  end

  def down
    change_column :repositories, :image_url, :string
  end
end
