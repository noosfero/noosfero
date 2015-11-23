module SuppliersPlugin::ProductHelper

  protected

  def supplier_choices suppliers
    @supplier_choices ||= suppliers.map do |s|
      [s.abbreviation_or_name, s.id]
    end.sort{ |a,b| a[0].downcase <=> b[0].downcase }
  end

end
