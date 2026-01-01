Rails.application.config.session_store :cookie_store,
    key: '_id_provider_session',
    secure: Rails.env.production? || Rails.application.config.assume_ssl,
    same_site: :lax,
    httponly: true