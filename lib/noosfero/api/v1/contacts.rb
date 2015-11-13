module Noosfero
  module API
    module V1
      class Contacts < Grape::API

        resource :communities do

          resource ':id/contact' do
            #contact => {:name => 'some name', :email => 'test@mail.com', :subject => 'some title', :message => 'some message'}
            desc "Send a contact message"
            post do
              profile = environment.communities.find(params[:id])
              forbidden! unless profile.present?
              contact = Contact.new params[:contact].merge(dest: profile)
              if contact.deliver
                {:success => true}
              else
                {:success => false}
              end
            end

          end
        end

      end
    end
  end
end
