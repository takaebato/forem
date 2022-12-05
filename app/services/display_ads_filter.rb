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
    relation = filter_by_approved_and_published

    if article_tags.any?
      relation = filter_by_article_tags(relation)
    end

    if article_tags.blank?
      relation = filter_in_articles_with_no_tags(relation)
    end

    relation = filter_by_user_sign_in(relation)
    relation.order(success_rate: :desc)

    if rand(8) == 1
      relation.sample
    else
      relation.limit(rand(1..15)).sample
    end
  end

  private

  attr_reader :area, :user_signed_in, :article_tags

  def filter_by_approved_and_published
    DisplayAd.approved_and_published.where(placement_area: area)
  end

  def filter_by_article_tags(relation)
    # relation.where(cached_tag_list: "") can be possibly moved out
    display_ads_with_no_tags = relation.where(cached_tag_list: "")
    display_ads_with_targeted_article_tags = relation.cached_tagged_with_any(article_tags)

    display_ads_with_no_tags.or(display_ads_with_targeted_article_tags)
  end

  def filter_in_articles_with_no_tags(relation)
    relation.where(cached_tag_list: "")
  end

  def filter_by_user_sign_in(relation)
    if user_signed_in
      relation.where(display_to: %w[all logged_in])
    else
      relation.where(display_to: %w[all logged_out])
    end
  end
end
