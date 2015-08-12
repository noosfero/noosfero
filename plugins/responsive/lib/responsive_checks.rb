
module ResponsiveChecks

  def theme_responsive?
    @theme_responsive = theme_option 'responsive' if @theme_responsive.nil?
    @theme_responsive
  end

end
