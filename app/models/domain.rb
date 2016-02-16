require 'noosfero/multi_tenancy'

class Domain < ActiveRecord::Base

  attr_accessible :name, :owner, :is_default

  # relationships
  ###############

  belongs_to :owner, :polymorphic => true

  # validations
  #############

  # <tt>name</tt> must be sequences of alphanumeric characters (a to z,
  # 0 to 9), plus '_' or '-', separated by dots. Letters must be lowercase.
  validates_format_of :name, with: /\A([a-z0-9_-]+\.)+[a-z0-9_-]+\z/, message: N_('{fn} must be composed of sequences of lowercase letters (a to z), numbers (0 to 9), "_" and "-", separated by dots.').fix_i18n

  # checks validations that could not be expressed using Rails' predefined
  # validations. In particular:
  # * <tt>name</tt> must not start with 'www.'
  validate :no_www

  def no_www
    if self.name =~ /^www\./
      self.errors.add(:name, _('{fn} must not start with www.').fix_i18n)
    end
  end

  # we cannot have two domains with the same name
  validates_uniqueness_of :name

  # businessl logic
  #################

  # finds a domain by its name. The argument <tt>name</tt> can start with
  # "www.", but it will be removed before searching. So searching for
  # 'www.example.net' is exactly the same as searching for just 'example.net'
  def self.find_by_name(name)
    self.where('name = ?', self.extract_domain_name(name)).first
  end

  # turns the argument (expected to be a String) into a domain name that is
  # accepted, by removing any leading 'www.' and turning the downcasing it.
  def self.extract_domain_name(name)
    name.downcase.sub(/^www\./, '')
  end

  # detects the Environment to which this domain belongs, either if it's
  # directly owned by one, or through a profile who owns the domain but belongs
  # to a Environment.
  def environment
    case owner
    when Environment
      owner
    when Profile
      owner.environment
    end
  end

  # returns the profile associated to this domain. Returns nil if the domain is
  # not directly associated with a profile.
  def profile
    case owner
    when Environment
      nil
    when Profile
      owner
    end
  end

  @hosting = {}

  # Tells whether the given domain name is hosting a profile or not.
  #
  # Since this is going to be called a lot, The queries are cached so the
  # database is hit only for the first query for a given domain name. This way,
  # transfering a domain from a profile to an environment of vice-versa
  # requires restarting the application.
  def self.hosting_profile_at(domainname)
    return false unless domainname
    Noosfero::MultiTenancy.setup!(domainname)
    @hosting[domainname] ||=
      begin
        domain = Domain.find_by_name(domainname)
        !domain.nil? && (domain.owner_type == 'Profile')
      end
  end

  # clears the cache of hosted domains. Used for testing.
  def self.clear_cache
    @hosting = {}
  end

  # Detects a domain's custom text domain chain if available based on a domain
  # served on multitenancy configuration or a registered domain.
  def self.custom_locale(domainname)
    domain = Noosfero::MultiTenancy.mapping[domainname] || domainname[/(.*?)\./,1]
    FastGettext.translation_repositories.keys.include?(domain) ? domain : FastGettext.default_text_domain
  end

end
