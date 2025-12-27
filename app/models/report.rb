class Report < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :game, counter_cache: :reports_count
  belongs_to :reviewed_by, class_name: "User", optional: true

  # Enums
  enum :reason, {
    inappropriate: 'inappropriate',
    broken: 'broken',
    offensive: 'offensive',
    spam: 'spam',
    other: 'other'
  }, prefix: true

  enum :status, {
    pending: 'pending',
    reviewed: 'reviewed',
    actioned: 'actioned',
    dismissed: 'dismissed'
  }, prefix: true

  # Validations
  validates :reason, presence: true

  # Callbacks
  after_create :check_auto_archive

  private

  def check_auto_archive
    # If a game receives 5 or more reports, auto-archive it
    if game.reports.count >= 5 && !game.status_archived?
      game.status_archived!
    end
  end
end
