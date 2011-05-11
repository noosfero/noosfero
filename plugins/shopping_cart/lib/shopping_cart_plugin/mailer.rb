include ApplicationHelper

class ShoppingCartPlugin::Mailer < Noosfero::Plugin::MailerBase

  prepend_view_path(ShoppingCartPlugin.root_path+'/views')

  def customer_notification(customer, supplier, items)
    domain = supplier.hostname || supplier.environment.default_hostname
    recipients    customer[:email]
    from          'no-reply@' + domain
    reply_to      supplier.contact_email
    subject       _("[%s] Your buy request was performed successfully.") % supplier[:name]
    content_type  'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment
  end

  def supplier_notification(customer, supplier, items)
    domain = supplier.environment.default_hostname
    recipients    supplier.contact_email
    from          'no-reply@' + domain
    reply_to      customer[:email]
    subject       _("[%s] You have a new buy request from %s.") % [supplier.environment.name, customer[:name]]
    content_type  'text/html'
    body :customer => customer,
         :supplier => supplier,
         :items => items,
         :environment => supplier.environment
  end
end
