include ApplicationHelper

class ShoppingCartPlugin::Mailer < ActionMailer::Base

  prepend_view_path(ShoppingCartPlugin.root_path+'/views')

  def customer_notification(customer, supplier, items)
    recipients    customer[:email]
    from          supplier.contact_email
    subject       _("[%s] Your buy request was performed successfully.") % supplier[:name]
    content_type  'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment
  end

  def supplier_notification(customer, supplier, items)
    recipients  supplier.contact_email
    from customer[:email]
    subject _("[%s] You have a new buy request from %s.") % [supplier.environment.name, customer[:name]]
    content_type 'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment
  end
end
