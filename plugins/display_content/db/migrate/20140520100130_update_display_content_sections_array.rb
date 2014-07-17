# encoding: UTF-8
class UpdateDisplayContentSectionsArray < ActiveRecord::Migration

  def self.up
    translator = {'Publish date' => 'publish_date', 'Title' => 'title', 'Abstract' => 'abstract', 'Body' => 'body', 'Image' => 'image', 'Tags' => 'tags',
                  'Data de publicação' => 'publish_date', 'Título' => 'title', 'Resumo' => 'abstract', 'Corpo' => 'body', 'Imagem' => 'image'}

    DisplayContentBlock.find_each do |block|
      new_sections = []

      block.sections.each do |section|
        new_value = translator[section["name"]]
        new_section = new_value.blank? ? section :  {:value => new_value, :checked => !section["checked"].blank? }

        new_section_to_update = new_sections.select {|s| s[:value] == new_value}.first
        if new_section_to_update.blank?
          new_sections << new_section
        else
          new_section_to_update[:checked] = new_section[:checked]
        end
      end
      block.sections = new_sections
      block.update_attribute(:settings, block.settings)
    end
  end

  def self.down
    raise "this migration can't be reverted"
  end

end
