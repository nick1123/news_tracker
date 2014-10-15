class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :phrase
      t.integer :occurences
      t.date :on_date
      t.integer :word_count

      t.timestamps
    end
  end
end
