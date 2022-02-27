# frozen_string_literal: true

require "thor"

module Todo
  # コマンドライン処理クラス
  class Command < Thor
    map %w[--version -v] => :version

    desc "--version, -v", "Print the version"
    def version
      puts Todo::VERSION
    end

    desc "create", "Create Todo Task"
    method_option :name, type: :string, aliases: "-n", required: true, desc: "The task name"
    method_option :content, type: :string, aliases: "-c", required: true, desc: "The task content"
    def create
      execute(:create, nil, options)
    end

    desc "update [id]", "Update Todo Task"
    method_option :name, type: :string, aliases: "-n", desc: "The task name"
    method_option :content, type: :string, aliases: "-c", desc: "The task content"
    method_option :status, type: :string, aliases: "-s", desc: "The task status"
    def update(id)
      execute(:update, id, options)
    end

    desc "delete [id]", "Delete Todo Task"
    def delete(id)
      execute(:delete, id, nil)
    end

    desc "list", "List Todo Tasks"
    method_option :status, type: :string, aliases: "-s", desc: "The task status"
    def list
      execute(:list, nil, options)
    end

    class << self
      # @return [Boolean] true
      def exit_on_failure?
        true
      end
    end

    private

    # コマンド処理
    #
    # @param command [Symbol] コマンド名
    # @param [Integer] id     更新、削除するタスクのID
    # @param [Hash] options   オプションデータ
    def execute(command, id, options)
      DB.prepare

      tasks =
        case command
        when :create
          create_task(options[:name], options[:content])
        when :update
          update_task(id, options)
        when :delete
          delete_task(id)
        when :list
          find_tasks(options[:status])
        end

      display_tasks tasks
      tasks
    rescue => e
      abort "ERROR: #{e.message}"
    end

    # タスクを登録
    #
    # @param name [String]    名前
    # @param content [String] 内容
    # @return [Todo::Task] 登録したタスク
    # @raise [ActiveRecord::RecordInvalid] 登録に失敗した場合
    def create_task(name, content)
      Task.create!(name: name, content: content).reload
    end

    # タスクを更新
    #
    # @param id [Integer]      ID
    # @param attributes [Hash] 更新データ
    # @option attributes [String] :name    名前
    # @option attributes [String] :content 内容
    # @option attributes [String] :status  ステータス("notyet", "done", "pending")
    # @return [Todo::Task] 更新したタスク
    # @raise [ActiveRecord::RecordNotFound] レコードが存在しない場合
    def update_task(id, attributes)
      task = Task.find(id)
      task.update! attributes
      task.reload
    end

    # タスクを削除
    #
    # @param id [Integer] ID
    # @return [Todo::Task] 削除したタスク
    # @raise [ActiveRecord::RecordNotFound] レコードが存在しない場合
    def delete_task(id)
      task = Task.find(id)
      task.destroy
    end

    # タスクを検索
    #
    # @param status [String, nil] ステータス("notyet", "done", "pending")
    # @return [ActiveRecord::Relation] タスクの配列
    def find_tasks(status = nil)
      all_tasks = Task.order("created_at DESC")

      if status
        all_tasks.where(status: status)
      else
        all_tasks
      end
    end

    # タスクのレコードを整形して出力
    #
    # @param tasks [Todo::Task, ActiveRecord::Relation] 出力するタスク
    def display_tasks(tasks)
      header = display_format("ID", "Name", "Content", "Status")

      puts header
      puts "-" * header.size
      Array(tasks).each do |task|
        puts display_format(task.id, task.name, task.content, task.status)
      end
    end

    # タスクのレコードを整形
    #
    # @param id [Fixnum, String] レコードのID
    # @param name [String]       レコードの名前
    # @param content [String]    レコードの内容
    # @param status [String]     レコードのステータス
    # @return [String] 表示用に整形された文字列
    def display_format(id, name, content, status)
      [
        id.to_s.rjust_ja(4),
        name.ljust_ja(20),
        content.ljust_ja(40),
        status.ljust_ja(10)
      ].join(" | ")
    end
  end
end
