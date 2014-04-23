require_dependency 'environment'

class Environment

  has_many :labels, :as => :owner, :class_name => 'CommentClassificationPlugin::Label'

end

