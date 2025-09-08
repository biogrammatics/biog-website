class ConsolidateUserMigrations < ActiveRecord::Migration[8.0]
  def up
    # This migration consolidates three separate user field migrations into the original users table
    # Since these are development migrations, we can clean them up

    # The fields have already been added by previous migrations, so this is a no-op
    # This migration exists to mark that we've consolidated the schema

    # Original migrations consolidated:
    # - 20250902214257_add_fields_to_users.rb (first_name, last_name)
    # - 20250902215622_add_admin_to_users.rb (admin boolean)
    # - 20250902225312_add_twist_username_to_users.rb (twist_username)
  end

  def down
    # No changes to revert since this is a documentation migration
  end
end
