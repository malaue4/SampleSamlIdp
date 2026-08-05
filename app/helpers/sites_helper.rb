module SitesHelper
  def saml_certificate_info(pem)
    return nil if pem.blank?

    cert = OpenSSL::X509::Certificate.new(pem)
    {
      subject: cert.subject.to_a.assoc("CN")&.at(1) || cert.subject.to_s,
      not_after: cert.not_after,
      fingerprint: OpenSSL::Digest.new("SHA256").hexdigest(cert.to_der).scan(/../).join(":").upcase,
      raw: pem,
      status: certificate_status(cert.not_after)
    }
  rescue StandardError => e
    Rails.logger.error "Failed to parse certificate: #{e.message}"
    nil
  end

  def certificate_status(not_after)
    if not_after < Time.current
      :expired
    elsif not_after < 30.days.from_now
      :expiring_soon
    else
      :valid
    end
  end

  def status_badge_class(status)
    case status
    when :expired then "text-bg-danger"
    when :expiring_soon then "text-bg-warning"
    else "text-bg-success"
    end
  end
end
