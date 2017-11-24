class Micropost < ApplicationRecord
  belongs_to :user
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true,
    length: {maximum: Settings.micropost.maximum_length}
  validate :picture_size
  scope :by_user, ->(id){where("user_id = ?", id)}
  scope :ordered_by_date, ->{order created_at: :desc}

  private

  def picture_size
    return if picture.size <= Settings.picture_upload.maximum_size.megabytes
    errors.add :picture, t("microposts.file_size_warnning")
  end
end
