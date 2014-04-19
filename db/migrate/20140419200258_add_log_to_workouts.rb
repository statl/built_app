class AddLogToWorkouts < ActiveRecord::Migration
  def change
    add_column :workouts, :log, :string
  end
end
