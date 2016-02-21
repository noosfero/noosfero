class Block < ApplicationRecord

  attr_accessible :title, :subtitle, :display, :limit, :box_id, :posts_per_page,
                  :visualization_format, :language, :display_user,
                  :box, :edit_modes, :move_modes, :mirror

  include ActionView::Helpers::TagHelper

  # Block-specific stuff
  include BlockHelper

  delegate :environment, :to => :box, :allow_nil => true

  acts_as_list scope: -> block { where box_id: block.box_id }

  belongs_to :box
  belongs_to :mirror_block, :class_name => "Block"
  has_many :observers, :class_name => "Block", :foreign_key => "mirror_block_id"

  acts_as_having_settings

  scope :enabled, -> { where :enabled => true }

  after_save do |block|
    if block.owner.kind_of?(Profile) && block.owner.is_template? && block.mirror?
      block.observers.each do |observer|
        observer.copy_from(block)
        observer.title = block.title
        observer.save
      end
    end
  end

  def embedable?
    false
  end

  def get_limit
    [0,limit.to_i].max
  end

  def embed_code
    me = self
    proc do
      content_tag('iframe', '',
        :src => url_for(:controller => 'embed', :action => 'block', :id => me.id, :only_path => false),
        :frameborder => 0,
        :width => 1024,
        :height => 768,
        :class => "embed block #{me.class.name.to_css_class}"
      )
    end
  end

  # Determines whether a given block must be visible. Optionally a
  # <tt>context</tt> must be specified. <tt>context</tt> must be a hash, and
  # may contain the following keys:
  #
  # * <tt>:article</tt>: the article being viewed currently
  # * <tt>:language</tt>: in which language the block will be displayed
  # * <tt>:user</tt>: the logged user
  def visible?(context = nil)
    return false if display == 'never'

    if context
      return false if language != 'all' && language != context[:locale]
      return false unless display_to_user?(context[:user])

      begin
        return self.send("display_#{display}", context)
      rescue NoMethodError => exception
        raise "Display '#{display}' is not a valid value."
      end
    end

    true
  end

  def display_to_user?(user)
    display_user == 'all' || (user.nil? && display_user == 'not_logged') || (user && display_user == 'logged') || (user && display_user == 'followers' && user.follows?(owner))
  end

  def display_always(context)
    true
  end

  def display_home_page_only(context)
    if context[:article]
      return context[:article] == owner.home_page
    else
      return home_page_path?(context[:request_path])
    end
  end

  def display_except_home_page(context)
    if context[:article]
      return context[:article] != owner.home_page
    else
      return !home_page_path?(context[:request_path])
    end
  end

  # The condition for displaying a block. It can assume the following values:
  #
  # * <tt>'always'</tt>: the block is always displayed
  # * <tt>'never'</tt>: the block is hidden (it does not appear for visitors)
  # * <tt>'home_page_only'</tt> the block is displayed only when viewing the
  #   homepage of its owner.
  # * <tt>'except_home_page'</tt> the block is displayed only when viewing
  #   the homepage of its owner.
  settings_items :display, :type => :string, :default => 'always'


  # The condition for displaying a block to users. It can assume the following values:
  #
  # * <tt>'all'</tt>: the block is always displayed
  # * <tt>'logged'</tt>: the block is displayed to logged users only
  # * <tt>'not_logged'</tt>: the block is displayed only to not logged users
  settings_items :display_user, :type => :string, :default => 'all'

  # The block can be configured to be displayed in all languages or in just one language. It can assume any locale of the environment:
  #
  # * <tt>'all'</tt>: the block is always displayed
  settings_items :language, :type => :string, :default => 'all'

  # The block can be configured to define the edition modes options. Only can be edited by environment admins
  # It can assume the following values:
  #
  # * <tt>'all'</tt>: the block owner has all edit options for this block
  # * <tt>'none'</tt>: the block owner can't do anything with the block
  settings_items :edit_modes, :type => :string, :default => 'all'
  settings_items :move_modes, :type => :string, :default => 'all'

  # returns the description of the block, used when the user sees a list of
  # blocks to choose one to include in the design.
  #
  # Must be redefined in subclasses to match the description of each block
  # type.
  def self.description
    '(dummy)'
  end

  def self.short_description
    self.pretty_name
  end

  def self.icon
    "/images/icon_block.png"
  end

  def self.icon_path
    basename = self.name.split('::').last.underscore
    File.join('images', 'blocks', basename, 'icon.png')
  end

  def self.pretty_name
    self.name.split('::').last.gsub('Block','')
  end

  def self.default_icon_path
    '/images/icon_block.png'
  end

  def self.preview_path
    base_name = self.name.split('::').last.underscore
    File.join('blocks', base_name,'previews')
  end

  def self.default_preview_path
    "/images/block_preview.png"
  end

  # Returns the content to be used for this block.
  #
  # This method can return several types of objects:
  #
  # * <tt>String</tt>: if the string starts with <tt>http://</tt> or <tt>https://</tt>, then it is assumed to be address of an IFRAME. Otherwise it's is used as regular HTML.
  # * <tt>Hash</tt>: the hash is used to build an URL that is used as the address for a IFRAME.
  # * <tt>Proc</tt>: the Proc is evaluated in the scope of BoxesHelper. The
  # block can then use <tt>render</tt>, <tt>link_to</tt>, etc.
  #
  # The method can also return <tt>nil</tt>, which means "no content".
  #
  # See BoxesHelper#extract_block_content for implementation details.
  def content(args={})
    "This is block number %d" % self.id
  end

  # A footer to be appended to the end of the block. Returns <tt>nil</tt>.
  #
  # Override in your subclasses. You can return the same types supported by
  # #content.
  def footer
    nil
  end

  # Is this block editable? (Default to <tt>true</tt>)
  def editable?(user=nil)
    self.edit_modes == "all"
  end

  def movable?
    self.move_modes == "all"
  end

  # must always return false, except on MainBlock clas.
  def main?
    false
  end

  def owner
    box ? box.owner : nil
  end

  def default_title
    ''
  end

  def title
    if self[:title].blank?
      self.default_title
    else
      self[:title]
    end
  end

  def view_title
    title
  end

  def cacheable?
    true
  end

  alias :active_record_cache_key :cache_key
  def cache_key(language='en', user=nil)
    active_record_cache_key + '-' + language
  end

  def timeout
    4.hours
  end

  def has_macro?
    false
  end

  # Override in your subclasses.
  # Define which events and context should cause the block cache to expire
  # Possible events are: :article, :profile, :friendship, :category, :role_assignment
  # Possible contexts are: :profile, :environment
  def self.expire_on
    {
      :profile => [],
      :environment => []
    }
  end

  DISPLAY_OPTIONS = {
    'always'           => _('In all pages'),
    'home_page_only'   => _('Only in the homepage'),
    'except_home_page' => _('In all pages, except in the homepage'),
    'never'            => _('Don\'t display'),
  }

  def display_options_available
    DISPLAY_OPTIONS.keys
  end

  def display_options
    DISPLAY_OPTIONS.slice(*display_options_available)
  end

  def display_user_options
    @display_user_options ||= {
      'all'            => _('All users'),
      'logged'         => _('Logged'),
      'not_logged'     => _('Not logged'),
      'followers'      => owner.class != Environment && owner.organization? ? _('Members') : _('Friends')
    }
  end

  def edit_block_options
    @edit_options ||= {
      'all'            => _('Can be modified'),
      'none'           => _('Cannot be modified')
    }
  end

  def move_block_options
    @move_options ||= {
      'all'            => _('Can be moved'),
      'none'           => _('Cannot be moved')
    }
  end


  def duplicate
    duplicated_block = self.dup
    duplicated_block.display = 'never'
    duplicated_block.created_at = nil
    duplicated_block.updated_at = nil
    duplicated_block.save!
    duplicated_block.insert_at(self.position + 1)
    duplicated_block
  end

  def copy_from(block)
    self.settings = block.settings
    self.position = block.position
  end

  def add_observer(block)
    self.observers << block
  end

  private

  def home_page_path
    home_page_url = Noosfero.root('/')

    if owner.kind_of?(Profile)
      home_page_url += "profile/" if owner.home_page.nil?
      home_page_url += owner.identifier
    end

    return home_page_url
  end

  def home_page_path? path
    return path == home_page_path || path == (home_page_path + '/')
  end

end
