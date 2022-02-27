# frozen_string_literal: true

require "active_record"

module Todo
  # tasksテーブルのモデルクラス
  class Task < ActiveRecord::Base
    # notyet 0 タスクが完了していない
    # done    1 タスクが完了した
    # pending 2 保留状態のタスク
    enum status: { notyet: 0, done: 1, pending: 2 }

    validates :name,    presence: true, length: { maximum: 140 }
    validates :content, presence: true
  end
end
