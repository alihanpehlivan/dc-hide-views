# frozen_string_literal: true

# name: discourse-hide-topic-views
# about: Properly hides topic view counts from public Discourse UI and JSON serializers.
# version: 0.1.0
# authors: Ali, ChatGPT
# url: https://example.invalid/discourse-hide-topic-views

module ::HideTopicViews
  PLUGIN_NAME = "discourse-hide-topic-views"

  module HideViewsSerializerPatch
    def include_views?
      false
    end
  end
end

after_initialize do
  reloadable_patch do
    # /latest.json, /new.json, category topic lists, tag topic lists, etc.
    if defined?(::TopicListItemSerializer)
      ::TopicListItemSerializer.prepend(::HideTopicViews::HideViewsSerializerPatch)
    end

    # /t/:slug/:id.json topic payload.
    if defined?(::TopicViewSerializer)
      ::TopicViewSerializer.prepend(::HideTopicViews::HideViewsSerializerPatch)
    end

    # Stop /latest?order=views from acting as a popularity side-channel.
    # If Discourse changes/freeze this mapping later, fail closed gently rather than breaking boot.
    begin
      if defined?(::TopicQuery::SORTABLE_MAPPING) && ::TopicQuery::SORTABLE_MAPPING.respond_to?(:delete)
        ::TopicQuery::SORTABLE_MAPPING.delete("views")
      end
    rescue StandardError => e
      Rails.logger.warn("[#{::HideTopicViews::PLUGIN_NAME}] Could not remove views sort mapping: #{e.class}: #{e.message}")
    end
  end
end
