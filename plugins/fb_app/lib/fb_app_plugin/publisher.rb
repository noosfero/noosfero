# Publishing examples on console
#   pub=FbAppPlugin::Publisher.default; u=Profile['brauliobo']; a=Article.find 307591
#   pub.publish_story a, u, :announce_news_from_a_sse_initiative
#
#   pub=FbAppPlugin::Publisher.default; u=Profile['brauliobo']; f=FavoriteEnterprisePerson.last
#   pub.publish_story f, u, :favorite_a_sse_initiative
#
class FbAppPlugin::Publisher < OpenGraphPlugin::Publisher

  def publish_story object_data, actor, story
    OpenGraphPlugin.context = FbAppPlugin::Activity.context
    a = FbAppPlugin::Activity.new object_data: object_data, actor: actor, story: story
    a.dispatch_publications
    a.save
  end

end
