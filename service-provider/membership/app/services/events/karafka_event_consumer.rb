# frozen_string_literal: true

module Events
  # Kafka-specific event consumer implementation
  # This adapter handles Kafka message format and delegates business logic to UserSyncService
  class KarafkaEventConsumer < EventConsumer
    def consume(event_type:, payload:)
      case event_type
      when "user.created"
        handle_user_created(payload)
      when "user.deleted"
        handle_user_deleted(payload)
      else
        Rails.logger.warn("Unknown event type: #{event_type}")
      end
    rescue StandardError => e
      Rails.logger.error("Failed to consume event #{event_type}: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise ConsumeError, "Event consumption failed: #{e.message}"
    end

    private

    def handle_user_created(payload)
      UserSyncService.sync_user_created(
        user_id: payload["user_id"],
        email: payload["email"],
        name: payload["name"],
      )
    end

    def handle_user_deleted(payload)
      UserSyncService.sync_user_deleted(user_id: payload["user_id"])
    end
  end
end
