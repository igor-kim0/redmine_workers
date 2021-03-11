class WorkersController < ApplicationController

    include QueriesHelper

    def index
        use_session = !request.format.csv?
        retrieve_query(IssueQuery, use_session)

        if @query.valid?

          Rails.logger.info "========================= #{@query.name}"

          respond_to do |format|
            format.html {
              @issue_count = @query.issue_count
              @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
              @issues = @query.issues(:offset => @issue_pages.offset, :limit => 500)
              render :layout => !request.xhr?
            }
          end
        else
          respond_to do |format|
            format.html { render :layout => !request.xhr? }
          end
        end
      rescue ActiveRecord::RecordNotFound
        render_404
    end

    def assigned_to
        status = "fail"
        if params[:issue_id] and params[:assigned_to]
            issue = Issue.find( params[:issue_id].to_i)
            journal = Journal.new(:journalized => issue, :user => User.current, :created_on => Time.now)
            issue.assigned_to_id = params[:assigned_to].to_i
            if issue.save
                journal.save 
                status = "ok"
            end
        end
        render locals: { status: status},  :layout => false, :template => 'workers/assigned_to'
    end
end
