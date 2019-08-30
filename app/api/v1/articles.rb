module Api
  module V1
    class Articles < Grape::API::Instance
      ARTICLE_TYPES = Article.descendants.map { |a| a.to_s }

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

        desc "Return all articles of all kinds" do
          detail "Get all articles filtered by fields in query params"
          params Entities::Article.documentation
          success Entities::Article
          failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
          named "ArticlesList"
          headers [
            "Per-Page" => {
              description: "Total number of records",
              required: false
            }
          ]
        end
        get do
          present_articles_for_asset(environment)
        end

        desc "Return one article by id" do
          detail 'Get only one article by id. If not found the "forbidden" http error is showed'
          params Entities::Article.documentation
          success Entities::Article
          failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
          named "ArticleById"
        end
        get ":id", requirements: { id: /[0-9]+/ } do
          present_article(environment)
        end

        post ":id" do
          article = environment.articles.find(params[:id])
          return forbidden! unless article.allow_edit?(current_person)

          begin
            article.update_attributes!(asset_with_image(params[:article]))
            present_partial article, with: Entities::Article
          rescue ActiveRecord::RecordInvalid
            render_model_errors!(article.errors)
          end
        end

        delete ":id" do
          article = environment.articles.find(params[:id])
          return forbidden! unless article.allow_delete?(current_person)

          begin
            article.destroy
            output = { success: true }
            output[:message] = _("The article %s was removed.") % article.title
            output[:code] = Api::Status::Http::NO_CONTENT
            present output, with: Entities::Response
          rescue Exception => exception
            render_api_error!(_("The article couldn't be removed due to some problem. Please contact the administrator."), Api::Status::Http::BAD_REQUEST)
          end
        end

        desc "Report a abuse and/or violent content in a article by id" do
          detail "Submit a abuse (in general, a content violation) report about a specific article"
          params Entities::Article.documentation
          failure [[Api::Status::Http::BAD_REQUEST, "Bad Request"]]
          named "ArticleReportAbuse"
        end
        post ":id/report_abuse" do
          article = find_article(environment.articles, id: params[:id])
          profile = article.profile
          begin
            abuse_report = AbuseReport.new(reason: params[:report_abuse])
            if !params[:content_type].blank?
              article = params[:content_type].constantize.find(params[:content_id])
              abuse_report.content = article_reported_version(article)
            end

            current_person.register_report(abuse_report, profile)

            if !params[:content_type].blank?
              abuse_report = AbuseReport.find_by reporter_id: current_person.id, abuse_complaint_id: profile.opened_abuse_complaint.id
              Delayed::Job.enqueue DownloadReportedImagesJob.new(abuse_report, article)
            end

            output = { success: true }
            output[:message] = _("Your abuse report was registered. The administrators are reviewing your report."),
                               output[:code] = Api::Status::WAITING_FOR_REVIEW

            present output, with: Entities::Response
          rescue Exception => exception
            # logger.error(exception.to_s)
            render_api_error!(_("Your report couldn't be saved due to some problem. Please contact the administrator."), Api::Status::Http::BAD_REQUEST)
          end
        end

        desc "Returns the articles I voted" do
          detail "Get the Articles I make a vote"
          failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
          named "ArticleFollowers"
        end
        # FIXME refactor this method
        get "voted_by_me" do
          present_articles(current_person.votes.where(voteable_type: "Article").collect(&:voteable))
        end

        desc "Perform a vote on a article by id" do
          detail "Vote on a specific article with values: 1 (if you like) or -1 (if not)"
          params Entities::UserLogin.documentation
          failure [[Api::Status::Http::UNAUTHORIZED, "Unauthorized"]]
          named "ArticleVote"
        end
        post ":id/vote" do
          authenticate!
          value = (params[:value] || 1).to_i
          # FIXME verify allowed values
          render_api_error!("Vote value not allowed", Api::Status::Http::BAD_REQUEST) unless [-1, 1].include?(value)
          article = find_article(environment.articles, id: params[:id])
          begin
            vote = Vote.new(voteable: article, voter: current_person, vote: value)
            vote.save!

            output = { success: true }
            output[:message] = _("Your vote was created.")
            output[:code] = Api::Status::Http::CREATED

            present output, with: Entities::Response
          rescue ActiveRecord::RecordInvalid => e
            render_model_errors!(vote.errors)
          end
        end

        desc "Return the articles followed by me"
        get "followed_by_me" do
          present_articles_for_asset(current_person, "following_articles")
        end

        desc "Add a follower for the article" do
          detail "Add the current user identified by private token, like a follower of a article"
          params Entities::UserLogin.documentation
          failure [[Api::Status::Http::UNAUTHORIZED, "Unauthorized"]]
          named "ArticleFollow"
        end
        post ":id/follow" do
          authenticate!
          article = find_article(environment.articles, id: params[:id])
          if article.article_followers.exists?(person_id: current_person.id)
            { success: false, already_follow: true }
            output = { success: false }
            output[:message] = _("You already follow this article.")
            output[:code] = Api::Status::Http::ALREADY_FOLLOW
          else
            article_follower = ArticleFollower.new
            article_follower.article = article
            article_follower.person = current_person
            article_follower.save!
            { success: true }
            output = { success: true }
            output[:message] = _("You are now following the article %s.") % article.title
            output[:code] = Api::Status::Http::CREATED
          end

          present output, with: Entities::Response
        end

        desc "Return the children of a article identified by id" do
          detail "Get all children articles of a specific article"
          params Entities::Article.documentation
          failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
          named "ArticleChildren"
        end

        paginate per_page: MAX_PER_PAGE, max_per_page: MAX_PER_PAGE
        get ":id/children" do
          article = find_article(environment.articles, id: params[:id])

          # TODO make tests for this situation
          votes_order = params.delete(:order) if params[:order] == "votes_score"
          articles = select_filtered_collection_of(article, "children", params)
          articles = articles.accessible_to(current_person)

          # TODO make tests for this situation
          if votes_order
            articles = articles.joins("left join votes on articles.id=votes.voteable_id").group("articles.id").reorder("sum(coalesce(votes.vote, 0)) DESC")
          end
          Article.hit(articles)
          present_articles(articles)
        end

        desc "Return one child of a article identified by id" do
          detail "Get a child of a specific article"
          params Entities::Article.documentation
          success Entities::Article
          failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
          named "ArticleChild"
        end
        get ":id/children/:child_id" do
          article = find_article(environment.articles, id: params[:id])
          child_params = {}
          child_params[:id] = params[:child_id]
          child = find_article(article.children, child_params)
          child.hit
          present_partial child, with: Entities::Article
        end

        desc "Suggest a article to another profile" do
          detail "Suggest a article to another profile (person, community...)"
          params Entities::Article.documentation
          success Entities::Task
          failure [[Api::Status::Http::UNAUTHORIZED, "Unauthorized"]]
          named "ArticleSuggest"
        end
        post ":id/children/suggest" do
          authenticate!
          parent_article = environment.articles.find(params[:id])

          suggest_article = SuggestArticle.new
          suggest_article.article = params[:article]
          suggest_article.article[:parent_id] = parent_article.id
          suggest_article.target = parent_article.profile
          suggest_article.requestor = current_person

          unless suggest_article.save
            render_model_errors!(suggest_article.article_object.errors)
          end
          present_partial suggest_article, with: Entities::Task
        end

        # Example Request:
        #  POST api/v1/articles/:id/children?private_token=234298743290432&article[name]=title&article[body]=body
        desc "Add a child article to a parent identified by id" do
          detail "Create a new article and associate to a parent"
          params Entities::Article.documentation
          success Entities::Article
          failure [[Api::Status::Http::UNAUTHORIZED, "Unauthorized"]]
          named "ArticleAddChild"
        end
        post ":id/children" do
          parent_article = environment.articles.find(params[:id])
          params[:article][:parent_id] = parent_article.id
          post_article(parent_article.profile, params)
        end
      end

      resource :profiles do
        get ":id/home_page" do
          profiles = environment.profiles
          profiles = profiles.accessible_to(current_person)
          profile = profiles.find_by id: params[:id]
          present_partial profile.home_page, with: Entities::Article
        end
      end

      kinds = %w[profile community person enterprise]
      kinds.each do |kind|
        resource kind.pluralize.to_sym do
          segment "/:#{kind}_id" do
            resource :articles do
              desc "Return all articles associate with a profile of type #{kind}" do
                detail "Get a list of articles of a profile"
                params Entities::Article.documentation
                success Entities::Article
                failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
                named "ArticlesOfProfile"
              end
              get do
                profile = environment.send(kind.pluralize).find(params["#{kind}_id"])

                present_articles_for_asset(profile)
              end

              desc "Return a article associate with a profile of type #{kind}" do
                detail "Get only one article of a profile"
                params Entities::Article.documentation
                success Entities::Article
                failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
                named "ArticleOfProfile"
              end
              get "/*id" do
                profile = environment.send(kind.pluralize).find(params["#{kind}_id"])
                key = (params[:key].present? && params[:key] == "path") ? :path : :id

                article = profile.articles.find_by(key => params[:id])
                if article && !article.display_to?(current_person)
                  article = forbidden!
                end
                article ||= not_found!

                present_partial article, with: Entities::Article, current_person: current_person
              end

              # Example Request:
              #  POST api/v1/{people,communities,enterprises}/:asset_id/articles?private_token=234298743290432&article[name]=title&article[body]=body
              desc "Add a new article associated with a profile of type #{kind}" do
                detail "Create a new article and associate with a profile"
                params Entities::Article.documentation
                success Entities::Article
                failure [[Api::Status::Http::FORBIDDEN, "Forbidden"]]
                named "ArticleCreateToProfile"
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
