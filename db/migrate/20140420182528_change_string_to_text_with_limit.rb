class ChangeStringToTextWithLimit < ActiveRecord::Migration
  def change
	change_column :workouts, :log, :text, :limit => nil
  end
end
