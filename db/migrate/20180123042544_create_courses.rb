class CreateCourses < ActiveRecord::Migration[5.1]
  def change
    create_table :courses do |t|
      t.string :name
      t.string :college
      t.string :department
      t.string :number
      t.string :section
      t.string :swapped_name
      t.string :swapped_college
      t.string :swapped_department
      t.string :swapped_number
      t.string :swapped_section
      t.string :swapped_lab
      t.string :add_or_swap
      t.string :loginemail
      t.string :loginpassword
      t.integer :user_id
      t.boolean :have_lab
      t.boolean :enrolledin, default: false
      t.string :lab1
      t.string :lab2
      t.string :lab3
      t.string :lab4
      t.timestamps
    end
  end
end
