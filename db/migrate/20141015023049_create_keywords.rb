class CreateKeywords < ActiveRecord::Migration
  def change
    create_table :keywords do |t|
      t.string :phrase, null: false
      t.integer :word_count
      t.integer :occurences, default: 1
      t.date :on_date

      t.timestamps
    end
  end
end
