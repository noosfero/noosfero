require 'active_support/inflector'
module Noosfero
  module API
    module Federation
      class Webfinger < Grape::API
        get "webfinger" do
          result = generate_jrd
          present result, :with => Grape::Presenters::Presenter
        end
      end
    end
  end
end

def generate_jrd
  result = {}
  if valid_domain? && request_acct?
    result = acct_hash
  elsif valid_domain? && valid_uri?(params[:resource])
    result = uri_hash
  end
end

def valid_domain?
  #validate domain if resource have acct
  if request_acct?
    domain  = params[:resource].split("@")[1]
    environment.domains.map(&:name).include? domain
  else
  #please validate domain with http
    false
  end
end

def request_acct?
  params[:resource].include? "acct:"
end

def acct_hash
  acct = {}
  acct[:subject] = params[:resource]
  acct[:properties] = Person.find_by_identifier(extract_person_identifier)
  acct
end

def extract_person_identifier
  person = params[:resource].split("@")[0].split(":")[1]
end

def valid_uri?(url)
  uri = URI.parse(url)
  uri.kind_of?(URI::HTTP)
  rescue URI::BadURIError
    "URI is valid, bad usage is not"
  rescue URI::InvalidURIError
    "invalid URI"
end

def uri_hash
  uri = {}
  uri[:subject] = params[:resource]
  entity = entity_exists?(params[:resource])
  id = params[:resource].split('/').last.to_i
  uri[:properties] = entity.classify.constantize.find(id)
  puts uri.inspect
  uri
end

def entity_exists?(uri)
  possible_entity = uri.split('/')
  possible_entity.map! {|entity| "#{entity}s"}
  ( ActiveRecord::Base.connection.tables & possible_entity ).first
  rescue ActiveRecord::RecordNotFound
    false
end

