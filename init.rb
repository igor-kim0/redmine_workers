require 'redmine'

Redmine::Plugin.register :redmine_workers do
    name 'Redmine workers plugin'
    author 'Igor Kishinskiy'
    description "Redmine workers plugin"
    version '0.0.1'
    url 'https://github.com/igor-kim0/redmine_workers'
    author_url 'https://github.com/igor-kim0/redmine_workers'


    menu :application_menu, :redmine_core_patch, { :controller => 'workers', :action => 'index' }, :caption => 'Workers'    
    menu :project_menu, :redmine_core_patch, { :controller => 'workers', :action => 'index' }, :caption => 'Workers', after: :settings, param: :project_id
    
    project_module :redmine_core_patch do
        permission :view_workers, {:workers => :index }
    end    
end