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

def extract_person_identifier
  person = params[:resource].split("@")[0].split(":")[1]
  person
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

def generate_jrd
  if valid_domain? && request_acct?
    result = {}
    result = acct_hash
  else
    "This Domain this not exist in this envinronment"
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
