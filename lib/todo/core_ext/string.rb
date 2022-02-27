# frozen_string_literal: true

module Todo
  # String拡張モジュール
  module CoreExt
    # 左寄せljustの日本語対応版
    #
    # @param width [Integer] 長さ
    # @param padstr [String] 埋める文字
    # @return [String] 左寄せ指定サイズの文字列
    # @example
    #   "テスト".ljust_ja(10)
    #   #=> "テスト    "
    def ljust_ja(width, padstr = " ")
      ljust(width, padstr) if length == length_ja

      self + padstr * margin_ja(width)
    end

    # 右寄せrjustの日本語対応版
    #
    # @param width [Integer] 長さ
    # @param padstr [String] 埋める文字
    # @return [String] 右寄せ指定サイズの文字列
    # @example
    #   "テスト".rjust_ja(10)
    #   #=> "    テスト"
    def rjust_ja(width, padstr = " ")
      rjust(width, padstr) if length == length_ja

      padstr * margin_ja(width) + self
    end

    # 中央寄せcenterの日本語対応版
    #
    # @param width [Integer] 長さ
    # @param padstr [String] 埋める文字
    # @return [String] 中央寄せ指定サイズの文字列
    # @example
    #   "テスト".center_ja(10)
    #   #=> "  テスト  "
    def center_ja(width, padstr = " ")
      center(width, padstr) if length == length_ja

      padstr * (margin_ja(width) / 2) + self + padstr * (margin_ja(width + 1) / 2)
    end

    private

    def margin_ja(width)
      [0, width - length_ja].max
    end

    def length_ja
      half_lenght = count(" -~\uFF61-\uFF9F")
      multi_length = (length - half_lenght) * 2
      half_lenght + multi_length
    end
  end
end

String.class_eval do
  include Todo::CoreExt
end
