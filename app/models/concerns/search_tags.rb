module SearchTags
  extend ActiveSupport::Concern

  def search_tags
    arg = params[:term].downcase
    result = Tag.where('name ILIKE ?', "%#{arg}%").limit(10)
    render :text => prepare_to_token_input_by_label(result).to_json, :content_type => 'application/json'
  end
end
