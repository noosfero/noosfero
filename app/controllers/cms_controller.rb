class CmsController < ComatoseAdminController
  self.template_root = File.join(File.dirname(__FILE__), '..', 'views')
end
