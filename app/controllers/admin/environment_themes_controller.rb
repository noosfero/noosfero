class EnvironmentThemesController < ThemesController

  protect 'edit_appearance', :environment
  
  no_design_blocks

  def target
    @target = environment
  end

end
