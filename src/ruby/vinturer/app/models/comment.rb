class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :chat_box
end
