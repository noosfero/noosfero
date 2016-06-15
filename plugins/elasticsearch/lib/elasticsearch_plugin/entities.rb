module Elasticsearch
  module Entities
    class Result < Api::Entity
      root "results","result"

      expose :type do |object, options|
        options[:types].detect { |type| type.to_s.upcase if object.is_a? (type.to_s.classify.constantize) }
      end

      expose :name

      expose :author, if: lambda { |object,options| object.respond_to? 'author'}  do |object, options|
        object.author.present? ? object.author.name : ""
      end
    end
  end
end
