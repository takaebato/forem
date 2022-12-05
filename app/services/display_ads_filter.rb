class DisplayAdsFilter
  def self.call(...)
    new(...).call
  end

  def initialize(area:, user_signed_in:, article_tags:)
    @area = area
    @user_signed_in = user_signed_in
    @article_tags = article_tags
  end

  def call
    relation = DisplayAd.approved_and_published.where(placement_area: area).order(success_rate: :desc)

    if article_tags.any?
      display_ads_with_no_tags = relation.where(cached_tag_list: "")
      display_ads_with_targeted_article_tags = relation.cached_tagged_with_any(article_tags)

      relation = display_ads_with_no_tags.or(display_ads_with_targeted_article_tags)
    end

    if article_tags.blank?
      relation = relation.where(cached_tag_list: "")
    end

    relation = if user_signed_in
                 relation.where(display_to: %w[all logged_in])
               else
                 relation.where(display_to: %w[all logged_out])
               end

    relation.order(success_rate: :desc)

    if rand(8) == 1
      relation.sample
    else
      relation.limit(rand(1..15)).sample
    end
  end

  private

  attr_reader :area, :user_signed_in, :article_tags
end
