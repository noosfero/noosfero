# Require `belongs_to` associations by default. Previous versions had false.
# If you want to make `belongs_to` relation optional, you should add in its `optional: true` directive
Rails.application.config.active_record.belongs_to_required_by_default = true