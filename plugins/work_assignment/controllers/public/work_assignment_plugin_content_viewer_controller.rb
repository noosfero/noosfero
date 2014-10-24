class WorkAssignmentPluginContentViewerController < ContentViewerController
	def toggle_friends_permission
		folder = environment.articles.find_by_id(params[:folder_id])
		puts "#{params[:folder_id]}"

		if folder
			author = folder.author
			work_assignment = folder.parent
			
			if !work_assignment.only_friends.include?(author)
				work_assignment.only_friends << author
			else
				work_assignment.only_friends.delete(author)
			end
		end
		redirect_to :action => :index
		#render :action => 'view'
	end
end