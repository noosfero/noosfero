module Elasticsearch
  module Entities

    class Result < Api::Entity
      root "results","result"

      expose :type do |object, options|
        options[:types].detect { |type| type.to_s.upcase if object.is_a? (type.to_s.classify.constantize) }
      end

      expose :id
      expose :name

      expose :author, if: lambda { |object,options| object.respond_to? 'author'}  do |object, options|
        object.author.present? ? object.author.name : ""
      end

      expose :description, if: lambda { |object,options| object.respond_to? 'description'}  do |object, options|
        object.description.present? ? object.description : ""
      end

      expose :abstract, if: lambda { |object,options| object.respond_to? 'abstract'}  do |object, options|
        object.abstract.present? ? object.abstract : ""
      end

      expose :created_at, :format_with => :timestamp
      expose :updated_at, :format_with => :timestamp
    end

  end
end
