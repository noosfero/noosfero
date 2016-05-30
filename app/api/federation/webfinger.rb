module Api
  module Federation
    class Webfinger < Grape::API
      get 'webfinger' do
        result = generate_jrd
        present result, with: Grape::Presenters::Presenter
      end
    end
  end
end

def generate_jrd
  unless valid_domain?
    not_found!
    Rails.logger.error 'Domain Not Found'
  end
  if request_acct?
    acct_hash
  elsif valid_uri?(params[:resource])
    uri_hash
  end
end

def domain
  if request_acct?
    params[:resource].split('@')[1]
  else
    params[:resource].split('/')[2]
  end
end

def valid_domain?
  environment.domains.map(&:name).include? domain
end

def request_acct?
  params[:resource].include? 'acct:'
end

def acct_hash
  acct = {}
  acct[:subject] = params[:resource]
  acct[:properties] = Person.find_by_identifier(extract_person_identifier)
  if acct[:properties].nil?
    Rails.logger.error 'Person not found'
    not_found!
  end
  acct
end

def extract_person_identifier
  params[:resource].split('@')[0].split(':')[1]
end

def valid_uri?(url)
  uri = URI.parse(url)
  if uri.is_a?(URI::HTTP)
    true
  else
    Rails.logger.error 'Bad URI Error'
    not_found!
  end
end

def uri_hash
  uri = {}
  uri[:subject] = params[:resource]
  entity = find_entity(params[:resource])
  id = params[:resource].split('/').last.to_i
  begin
    uri[:properties] = entity.classify.constantize.find(id)
  rescue ActiveRecord::RecordNotFound
    Rails.logger.error "Entity: #{entity} with id: #{id} not found"
    not_found!
  end
  uri
end

def find_entity(uri)
  possible_entity = uri.split('/')
  possible_entity.map! { |entity| "#{entity}s" }
  entity = (ActiveRecord::Base.connection.tables & possible_entity).first
  unless entity
    Rails.logger.error 'Entity not found on records'
    not_found!
  end
  entity
end
