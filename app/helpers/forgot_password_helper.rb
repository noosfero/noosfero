module ForgotPasswordHelper
  def plugins_options
    @plugins.dispatch(:change_password_fields)
  end

  def user_fields
    %w[login email] + plugins_options.select {|options| options[:model].to_sym == :user }.map { |options| options[:field].to_s }
  end

  def person_fields
    %w[] + plugins_options.select {|options| options[:model].to_sym == :person }.map { |options| options[:field].to_s }
  end

  def fields
    user_fields + person_fields
  end

  def fields_label
    labels = [
      _('Username'),
      _('Email'),
    ] + plugins_options.map { |options| options[:name] }

    last = labels.pop
    label = labels.join(', ')
    "#{label} #{_('or')} #{last}"
  end

  def build_query(fields, value)
    fields.map {|field| "#{field} = '#{value}'"}.join(' OR ')
  end

  def fetch_requestors(value)
    requestors = []
    person_query = build_query(person_fields, value)
    user_query = build_query(user_fields, value)

    requestors += Person.where(person_query).where(:environment_id => environment.id) if person_fields.present?
    requestors += User.where(user_query).where(:environment_id => environment.id).map(&:person) if user_fields.present?
    requestors
  end

end
