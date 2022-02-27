# frozen_string_literal: true

require "fileutils"
require "erb"
require "active_record"
require "active_support/all"

module Todo
  # データベース接続処理モジュール
  #
  # @example
  #   Todo::DB.prepare
  #   Todo::Task.create!(name: "タスク", content: "内容")
  module DB
    class << self
      # データベースに接続し、テーブルを作成
      def prepare
        # database_path = File.join(ENV["HOME"], ".todo", "todo.sqlite3")
        app_env = ENV.fetch("APP_ENV", "production")
        config = YAML.safe_load(ERB.new(File.read("lib/config/database.yml")).result)[app_env]
        connect_database config
        create_table_if_not_exists
      end

      private

      # データベースに接続
      #
      # @param config [Hash] 接続情報
      def connect_database(config)
        ActiveRecord::Base.logger = Todo.logger

        Time.zone_default = Time.find_zone!(local_time_zone)
        ActiveRecord::Base.time_zone_aware_attributes = true
        ActiveRecord.default_timezone = :utc

        FileUtils.mkdir_p File.dirname(config["database"])
        ActiveRecord::Base.establish_connection(config)
      end

      # tasksテーブルを作成
      def create_table_if_not_exists
        conn = ActiveRecord::Base.connection

        return if conn.data_source_exists?(:tasks)

        Todo.logger.debug "Create table tasks"

        conn.create_table :tasks do |t|
          t.string :name, null: false
          t.text :content, null: false
          t.integer :status, default: 0, null: false
          t.timestamps
          t.index :status
          t.index :created_at
        end
      end

      # OSのTimeZoneを取得
      #
      # @return [String] TimeZone
      def local_time_zone
        ENV["TZ"] || begin
          boy = Time.now.beginning_of_year
          jan_offset = boy.utc_offset
          jul_offset = boy.change(month: 7).utc_offset
          offset = jan_offset < jul_offset ? jan_offset : jul_offset
          ActiveSupport::TimeZone.all.detect { |zone| zone.utc_offset == offset }.tzinfo.name
        end
      end
    end
  end
end
