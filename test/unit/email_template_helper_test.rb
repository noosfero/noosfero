require_relative "../test_helper"

class EmailTemplateHelperTest < ActionView::TestCase

  should 'replace body and subject with parsed values from template' do
    template = mock
    template.expects(:parsed_body).returns('parsed body')
    template.expects(:parsed_subject).returns('parsed subject')
    params = {:subject => 'subject', :body => 'body', :email_template => template}
    expects(:mail).with({:subject => 'parsed subject', :body => 'parsed body', :content_type => 'text/html'})
    mail_with_template(params)
  end

  should 'do not change params if there is no email template' do
    params = {:subject => 'subject', :body => 'body'}
    expects(:mail).with(params)
    mail_with_template(params)
  end

end
