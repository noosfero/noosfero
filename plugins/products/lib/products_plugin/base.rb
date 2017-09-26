module ProductsPlugin
  class Base < Noosfero::Plugin

    def stylesheet?
      true
    end

    def js_files
      %w[products].map{ |j| "javascripts/#{j}" }
    end

    def self.extra_blocks
      {
        ProductsBlock => {type: [Enterprise] },
      }
    end

    def control_panel_buttons
      {
        title: _('Manage Products/Services'),
        icon:  'suppliers-manage-suppliers',
        url:   {controller: 'products_plugin/page'},
      } if profile.enterprise?
    end

    def profile_info_extra_contents
      lambda do
        render 'profile_editor/products_profile_info_contents'
      end
    end

    def content_types
      [EnterpriseHomepage] if context.kind_of?(Enterprise)
    end

    def extra_category_types(plural)
      [ [ n_('Product category', 'Product categories', plural), ProductCategory.sti_name ] ]
    end

  end
end

# STI compatibility
Product                = ProductsPlugin::Product
ProductsBlock          = ProductsPlugin::ProductsBlock
ProductCategoriesBlock = ProductsPlugin::ProductCategoriesBlock
ProductCategory        = ProductsPlugin::ProductCategory
FeaturedProductsBlock  = ProductsPlugin::FeaturedProductsBlock

# compatibility
Unit               = ProductsPlugin::Unit
Input              = ProductsPlugin::Input
Qualifier          = ProductsPlugin::Qualifier
Certifier          = ProductsPlugin::Certifier
QualifierCertifier = ProductsPlugin::QualifierCertifier
ProductQualifier   = ProductsPlugin::ProductQualifier
ProductionCost     = ProductsPlugin::ProductionCost
PriceDetail        = ProductsPlugin::PriceDetail

EnterpriseHomepage = ProductsPlugin::EnterpriseHomepage

