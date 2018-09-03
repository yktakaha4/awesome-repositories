class Autocomplete < ActiveRecord::Base
  def self.suggest
    %w(a abc abcde fff)
  end
end