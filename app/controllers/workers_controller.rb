class WorkersController < ApplicationController

    include QueriesHelper

    def index
        use_session = !request.format.csv?
        retrieve_query(IssueQuery, use_session)
        ### @project.descendants
 
        if @query.valid?
          respond_to do |format|
            format.html {
              @issue_count = @query.issue_count
              @issue_pages = Paginator.new @issue_count, per_page_option, params['page']
              @issues = @query.issues(:offset => @issue_pages.offset, :limit => 500)
              render :layout => !request.xhr?
            }
            format.api  {
              @offset, @limit = api_offset_and_limit
              @query.column_names = %w(author)
              @issue_count = @query.issue_count
              @issues = @query.issues(:offset => @offset, :limit => @limit)
              Issue.load_visible_relations(@issues) if include_in_api_response?('relations')
            }
            format.atom {
              @issues = @query.issues(:limit => Setting.feeds_limit.to_i)
              render_feed(@issues, :title => "#{@project || Setting.app_title}: #{l(:label_issue_plural)}")
            }
            format.csv  {
              @issues = @query.issues(:limit => Setting.issues_export_limit.to_i)
              send_data(query_to_csv(@issues, @query, params[:csv]), :type => 'text/csv; header=present', :filename => 'issues.csv')
            }
            format.pdf  {
              @issues = @query.issues(:limit => Setting.issues_export_limit.to_i)
              send_file_headers! :type => 'application/pdf', :filename => 'issues.pdf'
            }
          end
        else
          respond_to do |format|
            format.html { render :layout => !request.xhr? }
            format.any(:atom, :csv, :pdf) { head 422 }
            format.api { render_validation_errors(@query) }
          end
        end
      rescue ActiveRecord::RecordNotFound
        render_404

    end

    def assigned_to
        status = 'fail'
        if params[:issue_id] and params[:assigned_to]
            issue = Issue.find( params[:issue_id].to_i)
            journal = Journal.new(:journalized => issue, :user => User.current, :created_on => Time.now)
            issue.assigned_to_id = params[:assigned_to].to_i
            if issue.save
                journal.save 
                status = 'ok'
            end
        end
        render locals: { status: status},  :layout => false, :template => 'workers/assigned_to'
    end
    
end
