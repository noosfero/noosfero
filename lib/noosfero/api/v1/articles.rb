module Noosfero
  module API
    module V1
      class Articles < Grape::API

        ARTICLE_TYPES = Article.descendants.map{|a| a.to_s}

        MAX_PER_PAGE = 50

        resource :articles do

          paginate max_per_page: MAX_PER_PAGE
          # Collect articles
          #
          # Parameters:
          #   from             - date where the search will begin. If nothing is passed the default date will be the date of the first article created
          #   oldest           - Collect the oldest articles. If nothing is passed the newest articles are collected
          #   limit            - amount of articles returned. The default value is 20
          #
          # Example Request:
          #  GET host/api/v1/articles?from=2013-04-04-14:41:43&until=2015-04-04-14:41:43&limit=10&private_token=e96fff37c2238fdab074d1dcea8e6317

          desc 'Return all articles of all kinds' do
            detail 'Get all articles filtered by fields in query params'
            params Noosfero::API::Entities::Article.documentation
            success Noosfero::API::Entities::Article
            failure [[403, 'Forbidden']]
            named 'ArticlesList'
            headers [
              'Per-Page' => {
                    description: 'Total number of records',
                    required: false
                }
              ]
          end
          get do
            present_articles_for_asset(environment)
          end

          desc "Return one article by id" do
            detail 'Get only one article by id. If not found the "forbidden" http error is showed'
            params Noosfero::API::Entities::Article.documentation
            success Noosfero::API::Entities::Article
            failure [[403, 'Forbidden']]
            named 'ArticleById'
          end
          get ':id', requirements: {id: /[0-9]+/} do
            present_article(environment)
          end

          post ':id' do
            article = environment.articles.find(params[:id])
            return forbidden! unless article.allow_edit?(current_person)
            article.update_attributes!(params[:article])
            present_partial article, :with => Entities::Article
          end

          desc 'Report a abuse and/or violent content in a article by id' do
            detail 'Submit a abuse (in general, a content violation) report about a specific article'
            params Noosfero::API::Entities::Article.documentation
            failure [[400, 'Bad Request']]
            named 'ArticleReportAbuse'
          end
          post ':id/report_abuse' do
            article = find_article(environment.articles, params[:id])
            profile = article.profile
            begin
              abuse_report = AbuseReport.new(:reason => params[:report_abuse])
              if !params[:content_type].blank?
                article = params[:content_type].constantize.find(params[:content_id])
                abuse_report.content = article_reported_version(article)
              end

              current_person.register_report(abuse_report, profile)

              if !params[:content_type].blank?
                abuse_report = AbuseReport.find_by reporter_id: current_person.id, abuse_complaint_id: profile.opened_abuse_complaint.id
                Delayed::Job.enqueue DownloadReportedImagesJob.new(abuse_report, article)
              end

              {
                :success => true,
                :message => _('Your abuse report was registered. The administrators are reviewing your report.'),
              }
            rescue Exception => exception
              #logger.error(exception.to_s)
              render_api_error!(_('Your report couldn\'t be saved due to some problem. Please contact the administrator.'), 400)
            end

          end

          desc "Returns the articles I voted" do
            detail 'Get the Articles I make a vote'
            failure [[403, 'Forbidden']]
            named 'ArticleFollowers'
          end
           #FIXME refactor this method
          get 'voted_by_me' do
            present_articles(current_person.votes.where(:voteable_type => 'Article').collect(&:voteable))
          end

          desc 'Perform a vote on a article by id' do
            detail 'Vote on a specific article with values: 1 (if you like) or -1 (if not)'
            params Noosfero::API::Entities::UserLogin.documentation
            failure [[401,'Unauthorized']]
            named 'ArticleVote'
          end
          post ':id/vote' do
            authenticate!
            value = (params[:value] || 1).to_i
            # FIXME verify allowed values
            render_api_error!('Vote value not allowed', 400) unless [-1, 1].include?(value)
            article = find_article(environment.articles, params[:id])
            begin
              vote = Vote.new(:voteable => article, :voter => current_person, :vote => value)
              {:vote => vote.save!}
            rescue ActiveRecord::RecordInvalid => e
              render_api_error!(e.message, 400)
            end
          end

          desc "Returns the total followers for the article" do
            detail 'Get the followers of a specific article by id'
            failure [[403, 'Forbidden']]
            named 'ArticleFollowers'
          end
          get ':id/followers' do
            article = find_article(environment.articles, params[:id])
            total = article.person_followers.count
            {:total_followers => total}
          end

          desc "Return the articles followed by me"
          get 'followed_by_me' do
            present_articles_for_asset(current_person, 'following_articles')
          end

          desc "Add a follower for the article" do
            detail 'Add the current user identified by private token, like a follower of a article'
            params Noosfero::API::Entities::UserLogin.documentation
            failure [[401, 'Unauthorized']]
            named 'ArticleFollow'
          end
          post ':id/follow' do
            authenticate!
            article = find_article(environment.articles, params[:id])
            if article.article_followers.exists?(:person_id => current_person.id)
              {:success => false, :already_follow => true}
            else
              article_follower = ArticleFollower.new
              article_follower.article = article
              article_follower.person = current_person
              article_follower.save!
              {:success => true}
            end
          end

          desc 'Return the children of a article identified by id' do
            detail 'Get all children articles of a specific article'
            params Noosfero::API::Entities::Article.documentation
            failure [[403, 'Forbidden']]
            named 'ArticleChildren'
          end

          paginate per_page: MAX_PER_PAGE, max_per_page: MAX_PER_PAGE
          get ':id/children' do
            article = find_article(environment.articles, params[:id])

            #TODO make tests for this situation
            votes_order = params.delete(:order) if params[:order]=='votes_score'
            articles = select_filtered_collection_of(article, 'children', params)
            articles = articles.display_filter(current_person, article.profile)

            #TODO make tests for this situation
            if votes_order
              articles = articles.joins('left join votes on articles.id=votes.voteable_id').group('articles.id').reorder('sum(coalesce(votes.vote, 0)) DESC')
            end
            Article.hit(articles)
            present_articles(articles)
          end

          desc 'Return one child of a article identified by id' do
            detail 'Get a child of a specific article'
            params Noosfero::API::Entities::Article.documentation
            success Noosfero::API::Entities::Article
            failure [[403, 'Forbidden']]
            named 'ArticleChild'
          end
          get ':id/children/:child_id' do
            article = find_article(environment.articles, params[:id])
            child = find_article(article.children, params[:child_id])
            child.hit
            present_partial child, :with => Entities::Article
          end

          desc 'Suggest a article to another profile' do
            detail 'Suggest a article to another profile (person, community...)'
            params Noosfero::API::Entities::Article.documentation
            success Noosfero::API::Entities::Task
            failure [[401,'Unauthorized']]
            named 'ArticleSuggest'
          end
          post ':id/children/suggest' do
            authenticate!
            parent_article = environment.articles.find(params[:id])

            suggest_article = SuggestArticle.new
            suggest_article.article = params[:article]
            suggest_article.article[:parent_id] = parent_article.id
            suggest_article.target = parent_article.profile
            suggest_article.requestor = current_person

            unless suggest_article.save
              render_api_errors!(suggest_article.article_object.errors.full_messages)
            end
            present_partial suggest_article, :with => Entities::Task
          end

          # Example Request:
          #  POST api/v1/articles/:id/children?private_token=234298743290432&article[name]=title&article[body]=body
          desc 'Add a child article to a parent identified by id' do
            detail 'Create a new article and associate to a parent'
            params Noosfero::API::Entities::Article.documentation
            success Noosfero::API::Entities::Article
            failure [[401,'Unauthorized']]
            named 'ArticleAddChild'
          end
          post ':id/children' do
            authenticate!
            parent_article = environment.articles.find(params[:id])
            return forbidden! unless parent_article.allow_create?(current_person)

            klass_type= params[:content_type].nil? ? 'TinyMceArticle' : params[:content_type]
            #FIXME see how to check the article types
            #return forbidden! unless ARTICLE_TYPES.include?(klass_type)

            article = klass_type.constantize.new(params[:article])
            article.parent = parent_article
            article.last_changed_by = current_person
            article.created_by= current_person
            article.author= current_person
            article.profile = parent_article.profile

            if !article.save
              render_api_errors!(article.errors.full_messages)
            end
            present_partial article, :with => Entities::Article
          end

        end

        resource :profiles do
          get ':id/home_page' do
            profiles = environment.profiles
            profiles = profiles.visible_for_person(current_person)
            profile = profiles.find_by id: params[:id]
            present_partial profile.home_page, :with => Entities::Article
          end
        end

        kinds = %w[profile community person enterprise]
        kinds.each do |kind|
          resource kind.pluralize.to_sym do
            segment "/:#{kind}_id" do
              resource :articles do

                desc "Return all articles associate with a profile of type #{kind}" do
                  detail 'Get a list of articles of a profile'
                  params Noosfero::API::Entities::Article.documentation
                  success Noosfero::API::Entities::Article
                  failure [[403, 'Forbidden']]
                  named 'ArticlesOfProfile'
                end
                get do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])

                  if params[:path].present?
                    article = profile.articles.find_by path: params[:path]
                    if !article || !article.display_to?(current_person)
                      article = forbidden!
                    end

                    present_partial article, :with => Entities::Article
                  else

                    present_articles_for_asset(profile)
                  end
                end

                desc "Return a article associate with a profile of type #{kind}" do
                  detail 'Get only one article of a profile'
                  params Noosfero::API::Entities::Article.documentation
                  success Noosfero::API::Entities::Article
                  failure [[403, 'Forbidden']]
                  named 'ArticleOfProfile'
                end
                get ':id' do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  present_article(profile)
                end

                # Example Request:
                #  POST api/v1/{people,communities,enterprises}/:asset_id/articles?private_token=234298743290432&article[name]=title&article[body]=body
                desc "Add a new article associated with a profile of type #{kind}" do
                  detail 'Create a new article and associate with a profile'
                  params Noosfero::API::Entities::Article.documentation
                  success Noosfero::API::Entities::Article
                  failure [[403, 'Forbidden']]
                  named 'ArticleCreateToProfile'
                end
                post do
                  profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                  post_article(profile, params)
                end
              end
            end
          end
        end
      end
    end
  end
end
