# Require `belongs_to` associations by default. Previous versions had false.
# Se desejar tornar a relação `belongs_to` opcional, deverá adicionar na model a seguinte diretiva: `, optional: true`
Rails.application.config.active_record.belongs_to_required_by_default = true