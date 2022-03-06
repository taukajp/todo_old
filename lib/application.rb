# frozen_string_literal: true

require "sinatra/base"
require "sinatra/reloader"
require "rack-flash"

require "todo"

module Todo
  class Application < Sinatra::Base
    enable :sessions

    use Rack::MethodOverride
    use Rack::Flash

    configure do
      ENV["APP_ENV"] = ENV["RACK_ENV"]
      Todo.logger.level = Todo::Logging::LOG_LEVELS[:debug] if %w[development test].include?(ENV["APP_ENV"])
      DB.prepare
    end

    configure :development do
      register Sinatra::Reloader
    end

    helpers do
      def error_class(obj, name)
        "is-danger" if obj.errors.key?(name)
      end

      def error_message(obj, name)
        %(<p class="help is-danger">#{obj.errors.full_messages_for(name).first}</p>) if obj.errors.key?(name)
      end

      def options_for_task_status(task)
        Task.statuses.keys.map do |key|
          selected = task.status == key ? " selected" : ""
          %(<option value="#{key}"#{selected}>#{key.upcase}</option>)
        end.join
      end
    end

    not_found do
      slim :not_found
    end

    get "/" do
      redirect "/tasks"
    end

    get "/tasks" do
      @tasks = Task.order("created_at desc")
      @status = params[:status]
      @tasks = @tasks.where(status: @status) if @status

      slim :"tasks/index"
    end

    get "/tasks/new" do
      @task = Task.new

      slim :"tasks/new"
    end

    post "/tasks" do
      Task.create!(name: params[:name], content: params[:content])

      flash[:notice] = "Task was successfully created."
      redirect "/tasks"
    rescue ActiveRecord::RecordInvalid => e
      @task = e.record

      slim :"tasks/new"
    end

    get "/tasks/:id/edit" do |id|
      @task = Task.find(id)

      slim :"tasks/edit"
    rescue ActiveRecord::RecordNotFound
      error 404
    end

    patch "/tasks/:id" do |id|
      task = Task.find(id)
      task.update!(
        name: params[:name],
        content: params[:content],
        status: params[:status]
      )

      flash[:notice] = "Task was successfully updated."
      redirect "/tasks"
    rescue ActiveRecord::RecordInvalid => e
      @task = e.record

      slim :"tasks/edit"
    rescue ActiveRecord::RecordNotFound
      error 404
    end

    delete "/tasks/:id" do |id|
      task = Task.find(id)
      task.delete

      flash[:notice] = "Task was successfully destroyed."
      redirect "/tasks"
    rescue ActiveRecord::RecordNotFound
      error 404
    end
  end
end
