class CreateImportedFiles < ActiveRecord::Migration[7.0]
  def change
    create_table :imported_files do |t|
      t.string :checksum
      t.string :status

      t.text :preview

      t.timestamps
    end
  end
end
