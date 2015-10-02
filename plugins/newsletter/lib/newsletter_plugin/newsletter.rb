require 'csv'

class NewsletterPlugin::Newsletter < Noosfero::Plugin::ActiveRecord

  belongs_to :environment
  belongs_to :person
  validates_presence_of :environment, :person
  validates_uniqueness_of :environment_id
  validates_numericality_of :periodicity, only_integer: true, greater_than: -1, message: _('must be a positive number')
  validates_numericality_of :posts_per_blog, only_integer: true, greater_than: -1, message: _('must be a positive number')

  attr_accessible :environment, :enabled, :periodicity, :subject, :posts_per_blog, :footer, :blog_ids, :additional_recipients, :person, :person_id, :moderated

  scope :enabled, :conditions => { :enabled => true }

  # These methods are used by NewsletterMailing
  def people
    list = unsubscribers.map{|i| "'#{i}'"}.join(',')
    if list.empty?
      environment.people
    else
      environment.people.all(
        :joins => "LEFT OUTER JOIN users ON (users.id = profiles.user_id)",
        :conditions => "users.email NOT IN (#{list})"
      )
    end
  end

  def name
    environment.name
  end

  def contact_email
    environment.noreply_email
  end

  def top_url
    environment.top_url
  end

  def unsubscribe_url
    "#{top_url}/plugin/newsletter/unsubscribe"
  end

  serialize :blog_ids, Array
  serialize :additional_recipients, Array

  def blog_ids
    self[:blog_ids].map(&:to_i) || []
  end

  validates_each :blog_ids do |record, attr, value|
    if record.environment
      unless value.delete_if(&:zero?).select { |id| !Blog.find_by_id(id) || Blog.find(id).environment != record.environment }.empty?
        record.errors.add(attr, _('must be valid'))
      end
    end
    unless value.uniq.length == value.length
      record.errors.add(attr, _('must not have duplicates'))
    end
  end

  validates_each :additional_recipients do |record, attr, value|
    unless value.reject { |recipient| recipient[:email] =~ Noosfero::Constants::EMAIL_FORMAT }.empty?
      record.errors.add(attr, _('must have only valid emails'))
    end
  end

  def next_send_at
    (self.last_send_at || DateTime.now) + self.periodicity.days
  end

  def must_be_sent_today?
    return true unless self.last_send_at
    Date.today >= self.next_send_at.to_date
  end

  def blogs
    Blog.where(:id => blog_ids)
  end

  def posts(data = {})
    limit = self.posts_per_blog.zero? ? nil : self.posts_per_blog
    posts = if self.last_send_at.nil?
      self.blogs.map{|blog| blog.posts.all(:limit => limit)}.flatten
    else
      self.blogs.map{|blog| blog.posts.where("published_at >= :last_send_at", {last_send_at: self.last_send_at}).all(:limit => limit)}.flatten
    end
    data[:post_ids].nil? ? posts : posts.select{|post| data[:post_ids].include?(post.id.to_s)}
  end

  CSS = {
    'breakingnews-wrap' => 'background-color: #EFEFEF; padding: 40px 0',
    'breakingnews' => 'width: 640px; margin: auto; background-color: white; border: 1px solid #ddd; border-spacing: 0; padding: 0',
    'newsletter-public-link' => 'width: 640px; margin: auto; font-size: small; color: #555; font-style: italic; text-align: right; margin-bottom: 15px; font-family: sans;',
    'newsletter-header' => 'padding: 0',
    'header-image' => 'width: 100%',
    'post-image' => 'padding-left: 20px; width: 25%; border-bottom: 1px dashed #DDD',
    'post-info' => 'font-family: Arial, Verdana; padding: 20px; width: 75%; border-bottom: 1px dashed #DDD',
    'post-date' => 'font-size: 12px;',
    'post-lead' => 'font-size: 14px; text-align: justify',
    'post-title' => 'color: #000; text-decoration: none; font-size: 16px; text-align: justify',
    'read-more-line' => 'text-align: right',
    'read-more-link' => 'color: #000; font-size: 12px;',
    'newsletter-unsubscribe' => 'width: 640px; margin: auto; font-size: small; color: #555; font-style: italic; text-align: center; margin-top: 15px; font-family: sans;'
  }

  # to be able to generate HTML
  include ActionView::Helpers
  include Rails.application.routes.url_helpers
  include DatesHelper

  def message_to_public_link
    content_tag(:p, N_("If you can't view this email, %s.") % link_to(N_('click here'), '{mailing_url}'), :id => 'newsletter-public-link')
  end

  def message_to_unsubscribe
    content_tag(:div, N_("This is an automatically generated email, please do not reply. If you do not wish to receive future newsletter emails, %s.") % link_to(N_("cancel your subscription here"), self.unsubscribe_url, :style => CSS['public-link']), :style => CSS['newsletter-unsubscribe'], :id => 'newsletter-unsubscribe')
  end

  def read_more(link_address)
    content_tag(:p, link_to(N_('Read more'), link_address, :style => CSS['read-more-link']), :style => CSS['read-more-line'])
  end

  def post_with_image(post)
    content_tag(:tr,content_tag(:td,tag(:img, :src => "#{self.environment.top_url}#{post.image.public_filename(:big)}", :id => post.id),:style => CSS['post-image'])+content_tag(:td,content_tag(:span, show_date(post.published_at), :style => CSS['post-date'])+content_tag(:h3, link_to(h(post.title), post.url, :style => CSS['post-title']))+content_tag(:p,sanitize(post.lead(190)),:style => CSS['post-lead'])+read_more(post.url), :style => CSS['post-info']))
  end

  def post_without_image(post)
    content_tag(:tr, content_tag(:td,content_tag(:span, show_date(post.published_at),:style => CSS['post-date'], :id => post.id)+content_tag(:h3, link_to(h(post.title), post.url,:style => CSS['post-title']))+content_tag(:p,sanitize(post.lead(360)),:style => CSS['post-lead'])+read_more(post.url),:colspan => 2, :style => CSS['post-info']))
  end

  def body(data = {})
    content_tag(:div, content_tag(:div, message_to_public_link, :style => CSS['newsletter-public-link'])+content_tag(:table,(self.image.nil? ? '' : content_tag(:tr, content_tag(:th, tag(:img, :src => "#{self.environment.top_url}#{self.image.public_filename}", :style => CSS['header-image']),:colspan => 2),:style => CSS['newsletter-header']))+self.posts(data).map do |post|
        if post.image
          post_with_image(post)
        else
          post_without_image(post)
        end
      end.join()+content_tag(:tr, content_tag(:td, self.footer, :colspan => 2)),:style => CSS['breakingnews'])+content_tag(:div,message_to_unsubscribe, :style => CSS['newsletter-unsubscribe']),:style => CSS['breakingnews-wrap'])
  end

  def default_subject
    N_('Breaking news')
  end

  def subject
    self[:subject] || default_subject
  end

  def import_recipients(file, name_column = nil, email_column = nil, headers = nil)
    name_column ||= 1
    email_column ||= 2
    headers ||= false

    if File.extname(file.original_filename) == '.csv'
      [",", ";", "\t"].each do |sep|
        parsed_recipients = []
        CSV.foreach(file.path, { headers: headers, col_sep: sep }) do |row|
          parsed_recipients << {name: row[name_column.to_i - 1], email: row[email_column.to_i - 1]}
        end
        self.additional_recipients = parsed_recipients
        break if self.valid? || !self.errors.include?(:additional_recipients)
      end
    else
      #FIXME find a better way to deal with errors
      self.errors.add(:additional_recipients, _("have unknown file type: %s" % file.original_filename))
    end
  end

  acts_as_having_image

  def last_send_at
    last_mailing = NewsletterPlugin::NewsletterMailing.last(
      :conditions => {:source_id => self.id}
    )
    last_mailing.nil? ? nil : last_mailing.created_at
  end

  def sanitize(html)
    html.gsub(/<\/?p>/, '')
  end

  def has_posts_in_the_period?
    ! self.posts.empty?
  end

  serialize :unsubscribers, Array

  def unsubscribe(email)
    unsubscribers.push(email).uniq!
  end

end
