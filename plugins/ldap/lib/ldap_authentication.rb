# Redmine - project management software
# Copyright (C) 2006-2011  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'net/ldap'
require 'net/ldap/dn'
require 'magic'

class LdapAuthentication

  attr_accessor :host, :port, :account, :account_password, :base_dn, :attr_login, :attr_fullname, :attr_mail, :onthefly_register, :filter, :tls

  def initialize(attrs = {})
    self.host = attrs['host']
    self.port = attrs['port'].blank? ? 389 : attrs['port']
    self.account = attrs['account']
    self.account_password = attrs['account_password']
    self.base_dn = attrs['base_dn']
    self.attr_login = attrs['attr_login']
    self.attr_fullname = attrs['attr_fullname']
    self.attr_mail = attrs['attr_mail']
    self.onthefly_register = attrs['onthefly_register']
    self.filter = attrs['filter']
    self.tls = attrs['tls']
  end

  def onthefly_register?
    self.onthefly_register == true
  end

  def authenticate(login, password)
    return nil if login.blank? || password.blank?
    attrs = get_user_dn(login, password)

    if attrs && attrs[:dn] && authenticate_dn(attrs[:dn], password)
      return attrs.except(:dn)
    end
  end

  private

  def ldap_filter
    if filter.present?
      Net::LDAP::Filter.construct(filter)
    end
  rescue Net::LDAP::LdapError
    nil
  end

  def validate_filter
    if filter.present? && ldap_filter.nil?
      errors.add(:filter, :invalid)
    end
  end

  def initialize_ldap_con(ldap_user, ldap_password)
    options = { :host => self.host,
                :port => self.port,
                :encryption => (self.tls ? :simple_tls : nil)
              }
    options.merge!(:auth => { :method => :simple, :username => ldap_user, :password => ldap_password }) unless ldap_user.blank? && ldap_password.blank?
    Net::LDAP.new options
  end

  def get_user_attributes_from_ldap_entry(entry)
    attributes = entry.instance_values["myhash"]

    attributes[:dn] = entry.dn
    attributes[:fullname] = LdapAuthentication.get_attr(entry, self.attr_fullname)
    attributes[:mail] = LdapAuthentication.get_attr(entry, self.attr_mail)

    attributes
  end

  # Return the attributes needed for the LDAP search.  It will only
  # include the user attributes if on-the-fly registration is enabled
  def search_attributes
    if onthefly_register?
      nil
    else
      ['dn']
    end
  end

  # Check if a DN (user record) authenticates with the password
  def authenticate_dn(dn, password)
    if dn.present? && password.present?
      initialize_ldap_con(dn, password).bind
    end
  end

  # Get the user's dn and any attributes for them, given their login
  def get_user_dn(login, password)
    ldap_con = nil
    if self.account && self.account.include?("$login")
      ldap_con = initialize_ldap_con(self.account.sub("$login", Net::LDAP::DN.escape(login)), password)
    else
      ldap_con = initialize_ldap_con(self.account, self.account_password)
    end
    login_filter = nil
    (self.attr_login || []).split.each do |attr|
      if(login_filter.nil?)
        login_filter = Net::LDAP::Filter.eq( attr, login )
      else
        login_filter = login_filter | Net::LDAP::Filter.eq( attr, login )
      end
    end
    object_filter = Net::LDAP::Filter.eq( "objectClass", "*" )

    attrs = {}

    search_filter = object_filter & login_filter
    if f = ldap_filter
      search_filter = search_filter & f
    end

    ldap_con.search( :base => self.base_dn, :filter => search_filter, :attributes=> search_attributes) do |entry|
      if onthefly_register?
        attrs = get_user_attributes_from_ldap_entry(entry)
      else
        attrs = {:dn => entry.dn}
      end
    end

    attrs
  end

  def self.get_attr(entry, attr_name)
    if !attr_name.blank?
      val = entry[attr_name].is_a?(Array) ? entry[attr_name].first : entry[attr_name]
      if val.nil?
        Rails.logger.warn "LDAP entry #{entry.dn} has no attr #{attr_name}."
        nil
      elsif val == '' || val == ' '
        Rails.logger.warn "LDAP entry #{entry.dn} has attr #{attr_name} empty."
        ''
      else
        charset = Magic.guess_string_mime_encoding(val)
        val.encode 'utf-8', charset, invalid: :replace, undef: :replace
      end
    end
  end

end
