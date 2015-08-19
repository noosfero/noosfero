module OrdersPlugin::Report

  protected

  def report_products_by_supplier products_by_suppliers
    p = Axlsx::Package.new
    p.use_autowidth = true
    wb = p.workbook

    # create styles
    defaults   = {fg_color: "000000", sz: 8, alignment: { :horizontal=> :left, vertical: :center, wrap_text: false }, border: 0}
    redcell    = wb.styles.add_style bg_color: "E8D0DC", fg_color: "000000", sz: 8, b: true, wrap_text: true, alignment: { :horizontal=> :left }, border: 0
    yellowcell = wb.styles.add_style bg_color: "FCE943", fg_color: "000000", sz: 9, b: true, wrap_text: true, alignment: { :horizontal=> :left }, border: 0
    greencell  = wb.styles.add_style(defaults.merge({bg_color: "00AE00", fg_color: "ffffff", b: true }))
    bluecell   = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true}))
    default    = wb.styles.add_style(defaults.merge({border: 0}))
    #bluecell_b_top  = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true, border: {style: :thin, color: "FF000000", edges: [:top]}}))
    #date  = wb.styles.add_style(defaults.merge({format_code: t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
    currency   = wb.styles.add_style(defaults.merge({format_code: t('number.currency.format.xlsx_currency')}))
    #border_top = wb.styles.add_style border: {style: :thin, color: "FF000000", edges: [:top]}

    # supplier block start index (shifts on the loop for each supplier)
    sbs = 3
    # create sheet and populates
    wb.add_worksheet(name: t('lib.report.products_report')) do |sheet|

      sheet.add_row [t('lib.report.alert_formulas'),"","","","","","","","","",""], style: yellowcell
      sheet.add_row [""]
      sheet.merge_cells "A1:K1"
      total_selled_sum = 0
      total_parcelled_sum = 0
      products_by_suppliers.each do |supplier, products|
        next if supplier.blank?
        sheet.add_row [t('lib.report.supplier'),'',t('lib.report.phone'),'',t('lib.report.mail'),'','','','','',''], style: bluecell
        sheet.merge_cells "A#{sbs}:B#{sbs}"

        selled_sum = 0
        parcelled_sum = 0
        # sp = index of the start of the products list / ep = index of the end of the products list
        sp = sbs + 3
        ep = sp + products.count - 1
        sheet.add_row [supplier.abbreviation_or_name, '', supplier.profile.contact_phone, '',supplier.profile.contact_email, '', '', '', '', '', ''],
          style: default
        sbe = sbs+1
        ["A#{sbe}:B#{sbe}","C#{sbe}:D#{sbe}", "E#{sbe}:F#{sbe}"].each{ |c| sheet.merge_cells c }

        sheet.add_row [
          t('lib.report.product_cod'), t('lib.report.product_name'), t('lib.report.qty_ordered'),
          t('lib.report.stock_qtt'), t('lib.report.min_stock'), t('lib.report.qtt_to_be_parcelled'),t('lib.report.projected_stock'),
          t('lib.report.un'), t('lib.report.price_un'), t('lib.report.selled_value'), t('lib.report.value_parcel')
        ], style: greencell

        # pl = product line
        pl = sp
        products.each do |product|

          stock_qty_formula = "=IF(C#{pl}-D#{pl}+E#{pl}>0, C#{pl}-D#{pl}+E#{pl},0)"
          stock_qty_value = product.quantity_ordered
          stock_formula = "=D#{pl}-C#{pl}+F#{pl}"
          stock_value = 0
          unit = product.unit.singular rescue ''
          total_price_formula = "=F#{pl}*I#{pl}"
          total_price_value = product.quantity_ordered * product.price rescue 0

          #FIXME: correct this calc for stock
          selled_sum += total_price_value
          parcelled_sum += total_price_value

          sheet.add_row [product.id, product.name, product.quantity_ordered,
                         0, 0, stock_qty_formula, stock_formula,
                         unit, product.price, total_price_value, total_price_formula],
            style: [default,default,default,
                    default,default,default,default,
                    default,currency,currency,currency],
            formula_values: [nil,nil,nil,
                             nil,nil,stock_qty_value,stock_value,
                             nil,nil,nil,total_price_value]

          pl +=1
        end

        total_selled_sum += selled_sum
        total_parcelled_sum += parcelled_sum

        sheet.add_row [t('lib.report.total_selled_value'), '', "=SUM(J#{sp}:J#{ep})",
                       t('lib.report.total_parcel_value'), '', "=SUM(k#{sp}:k#{ep})",
                       '', '', '', ''],
          formula_values: [nil,nil, selled_sum,
                           nil,nil, parcelled_sum,
                           nil,nil,nil, nil],
            style: [redcell,redcell,currency,
                    redcell,redcell,currency,
                    default,default,default, default]

        row = ep+1
        ["A#{row}:B#{row}", "D#{row}::#{row}"].each{ |c| sheet.merge_cells c }

        sheet.add_row ['']

        sbs = ep + 3

      end

      sheet.add_row [t('lib.report.selled_total'), "=SUM(J1:J1000)", t('lib.report.parcelled_total'), "=SUM(K1:K1000)"],
        style: [redcell, default, redcell, default],
        formula_values: [nil, total_selled_sum, nil,total_parcelled_sum]

      sheet.column_widths 11,29,13,10,12,12,12,10,10,14,14

    end # closes spreadsheet

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'

    p.serialize report_file
    report_file
  end

  def report_orders_by_consumer orders
    p = Axlsx::Package.new
    wb = p.workbook

    # create styles
    defaults   = {fg_color: "000000", sz: 8, alignment: {horizontal: :left, vertical: :center, wrap_text: true}, border: 0}
    greencell  = wb.styles.add_style(defaults.merge({bg_color: "00AE00", fg_color: "ffffff", b: true }))
    bluecell   = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true}))
    default    = wb.styles.add_style(defaults.merge({border: 0}))
    bluecell_b_top  = wb.styles.add_style(defaults.merge({bg_color: "99CCFF", b: true, border: {style: :thin, color: "FF000000", edges: [:top]}}))
    date       = wb.styles.add_style(defaults.merge({format_code: t('lib.report.mm_dd_yy_hh_mm_am_pm')}))
    currency   = wb.styles.add_style(defaults.merge({format_code: t('number.currency.format.xlsx_currency')}))
    #border_top = wb.styles.add_style border: {style: :thin, color: "FF000000", edges: [:top]}
    redcell    = wb.styles.add_style bg_color: "E8D0DC", fg_color: "000000", sz: 8, b: true, wrap_text: true, alignment: { :horizontal=> :left }, border: 0
    yellowcell = wb.styles.add_style bg_color: "FCE943", fg_color: "000000", sz: 9, b: true, wrap_text: true, alignment: { :horizontal=> :left }, border: 0

    # create sheet and populates
    wb.add_worksheet(name: t('lib.report.closed_orders')) do |sheet|
      # supplier block start index (shifts on the loop for each supplier)
      sbs = 3
      sheet.add_row [t('lib.report.alert_formulas'),"","","","","",""], style: yellowcell
      sheet.add_row [""]
      sheet.merge_cells "A1:G1"
      productsStart = sbs+5
      productsEnd = 0
      selled_sum = 0
      orders.each do |order|

        sheet.add_row [t('lib.report.order_code'), t('lib.report.member_name'), '', t('lib.report.phone'), '', t('lib.report.mail'), ''], style: bluecell_b_top
        ["B#{sbs}:C#{sbs}", "D#{sbs}:E#{sbs}", "F#{sbs}:G#{sbs}"].each{ |c| sheet.merge_cells c }
        sbs += 1
        sheet.add_row [order.code, order.consumer_data[:name], '',order.consumer_data[:contact_phone],'',order.consumer_data[:email],''], style: default
        ["B#{sbs}:C#{sbs}", "D#{sbs}:E#{sbs}", "F#{sbs}:G#{sbs}"].each{ |c| sheet.merge_cells c }

        sbs += 1
        sheet.add_row [t('lib.report.created'), t('lib.report.modified'), t('lib.report.payment_method'), t('lib.report.delivery_option'), '','',''],
          style: bluecell
        ["D#{sbs}:E#{sbs}"].each{ |c| sheet.merge_cells c }
        # sp = index of the start of the products list / ep = index of the end of the products list
        sp = sbs + 3
        productsEnd = ep = sp + order.items.count - 1
        payment_method = _ OrdersPlugin::Order::PaymentMethods[order.payment_data[:method].to_sym].call rescue ''
        sheet.add_row [order.created_at, order.updated_at, payment_method, order.supplier_delivery_data[:name], '', '','',''],
          style: [date, date, default, default]
        sbs += 1
        sheet.add_row [t('lib.report.product_cod'), t('lib.report.supplier'), t('lib.report.product_name'),
                       t('lib.report.qty_ordered'),t('lib.report.un'),t('lib.report.price_un'), t('lib.report.value')], style: greencell
        ["D#{sbs}:E#{sbs}"].each{ |c| sheet.merge_cells c }

        sbe = sp
        sum = 0
        order.items.each do |item|

          formula_value = item.price * item.status_quantity rescue 0
          formula_value_s = CurrencyHelper.localized_number(formula_value)
          unit = item.product.unit.singular rescue ''

          # for the case in which the item is aggregated by other products we chose to use the item idhave to
          if item.supplier_products.size > 1
            id = item.id
          else
            id = item.supplier_products.first.id rescue item.id
          end
          supplier_name = item.suppliers.first.abbreviation_or_name rescue item.order.profile.name

          sheet.add_row [id, supplier_name,
                         item.name, item.status_quantity,
                         unit, item.product.price,
                         "=F#{sbe}*D#{sbe}"],
          style: [default,default,default,default,default,currency,currency],
          formula_values: [nil,nil,nil,nil,nil,nil,formula_value_s]
          selled_sum += item.status_quantity * item.price rescue 0

          sbe += 1
          sum += formula_value
        end # closes order.items.each

        sheet.add_row ['','','','',t('lib.report.total_value'),"=SUM(G#{sp}:G#{ep})", ''], style: [default]*4+[bluecell,currency, default],
          formula_values: [nil,nil,nil,nil,nil,sum, nil]

        sheet.add_row [""]
        sbs = sbe + 2
      end

      sheet.add_row [t('lib.report.selled_total'), '', "=SUM(G#{productsStart}:G#{productsEnd})"],
        formula_values: [nil,nil, selled_sum],
        style: [redcell,redcell,currency]

      ["A#{sbs}:B#{sbs}"].each{ |c| sheet.merge_cells c }


      sheet.column_widths 15,30,30,9,8,10,11
    end # closes spreadsheet

    tmp_dir = Dir.mktmpdir "noosfero-"
    report_file = tmp_dir + '/report.xlsx'
    p.serialize report_file
    report_file
  end # closes def

end

