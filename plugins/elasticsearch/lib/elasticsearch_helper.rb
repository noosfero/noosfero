module INDEXED_MODEL
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  def self.included base
    base.extend ClassMethods
  end

  module ClassMethods
#	  settings index: { number_of_shards: 1 } do
#		mappings dynamic: 'false' do
#		  self::SEARCHABLE_FIELDS.each do |field, value|
#			indexes field
#		  end
#		end
#	 
#		self.__elasticsearch__.client.indices.delete \
#		  index: self.index_name rescue nil
#	 
#		self.__elasticsearch__.client.indices.create \
#		  index: self.index_name,
#		  body: {
#			  settings: self.settings.to_hash,
#			  mappings: self.mappings.to_hash
#		  }
#	 
#		self.import
#	  end
  end
end

