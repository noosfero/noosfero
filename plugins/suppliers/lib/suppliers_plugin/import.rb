require 'csv'
require 'charlock_holmes'

class SuppliersPlugin::Import

  def self.product_columns header
    keys = I18n.t'suppliers_plugin.lib.import.keys'
    columns = []
    header.each do |name|
      c = nil; keys.each do |key, regex|
        if /#{regex}/i =~ name
          c = key
          break
        end
      end
      raise "duplicate column match '#{name}' already added as :#{c}" if c and c.in? columns
      columns << c
    end
    # check required fields
    return if ([:supplier_name, :product_name, :price] - columns).present?
    columns
  end

  def self.products consumer, csv
    default_product_category = consumer.environment.product_categories.find_by_name 'Produtos'

    detection = CharlockHolmes::EncodingDetector.detect csv
    csv = CharlockHolmes::Converter.convert csv, detection[:encoding], 'UTF-8'
    data = {}
    rows = []
    columns = []
    quote_chars = %w[" | ~ ^ & *]
    [",", ";", "\t"].each do |sep|
      begin
        rows = CSV.parse csv, quote_char: quote_chars.shift, col_sep: sep
        columns = self.product_columns rows.first
      rescue
        if quote_chars.empty? then raise else retry end
      ensure
        break if columns.present?
      end
    end
    rows.shift
    raise "can't find required columns" if columns.blank?

    # extract and treat attributes
    rows.each do |row|
      attrs = {}; row.each.with_index do |value, i|
        next unless c = columns[i]
        value = value.to_s.squish
        attrs[c] = if value.present? then value else nil end
      end

      distributed = attrs[:distributed] = {}
      distributed[:external_id] = attrs.delete :external_id
      if supplier_price = attrs.delete(:supplier_price)
        distributed[:price] = attrs[:price]
        attrs[:price] = supplier_price
      end

      attrs[:name] = attrs.delete :product_name
      if product_category = attrs[:product_category]
        attrs[:product_category] = ProductCategory.find_by_solr(product_category, query_fields: ['name']).first
      end
      attrs[:product_category] ||= default_product_category
      if qualifiers = attrs[:qualifiers]
        qualifiers = JSON.parse qualifiers
        qualifiers.map! do |q|
          next if q.blank?
          Qualifier.find_by_solr(q, query_fields: ['name']).first
        end.compact!
        attrs[:qualifiers] = qualifiers
      end
      attrs[:unit] = consumer.environment.units.where(singular: attrs[:unit]).first || SuppliersPlugin::BaseProduct.default_unit
      # FIXME
      attrs.delete :stock

      if composition = attrs.delete(:composition)
        composition = JSON.parse composition rescue nil
        distributed[:price_details] = composition.map do |name, price|
          production_cost = consumer.environment.production_costs.where(name: name).first
          production_cost ||= consumer.production_costs.where(name: name).first
          production_cost ||= consumer.production_costs.create! name: name, owner: profile
          PriceDetail.new production_cost: production_cost, price: price
        end
      end

      # treat URLs
      profile = nil
      if product_url = attrs.delete(:product_url) and /manage_products\/show\/(\d+)/ =~ product_url
        product = Product.where(id: $1).first
        next if product.blank?
        attrs[:record] = product
        profile = product.profile
      end
      if supplier_url = attrs.delete(:supplier_url)
        uri = URI.parse supplier_url
        profile = Domain.where(name: uri.host).first.profile rescue nil
        profile ||= Profile.where(identifier: Rails.application.routes.recognize_path(uri.path)[:profile]).first
        next if profile.blank?
      end
      supplier_name = attrs.delete :supplier_name
      supplier = profile || supplier_name

      data[supplier] ||= []
      data[supplier] << attrs
    end

    data.each do |supplier, products|
      if supplier.is_a? Profile
        supplier = consumer.add_supplier supplier, distribute_products_on_create: false
      else
        supplier_name = supplier
        supplier = consumer.suppliers.where(name: supplier_name).first
        supplier ||= SuppliersPlugin::Supplier.create_dummy consumer: consumer, name: supplier_name
      end

      products.each do |attrs|
        distributed_attrs = attrs.delete :distributed

        product = attrs.delete :record
        product ||= supplier.profile.products.where(name: attrs[:name]).first
        product ||= supplier.profile.products.build attrs
        # let update happen only on dummy suppliers
        if product.persisted? and supplier.dummy?
          product.update_attributes! attrs
        elsif product.new_record?
          # create products as not available
          attrs[:available] = false if not supplier.dummy?
          product.update_attributes! attrs
        end

        distributed_product = product.distribute_to_consumer consumer, distributed_attrs
      end
    end
  end

end
