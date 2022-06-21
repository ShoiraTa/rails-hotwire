class Message < ApplicationRecord
  validates :body, presence: true,length: { is: 7 }
end
