'use strict'

// base URL
exports.base_url = process.env.MFA_BASE_URL

// desired tomezone for logs
exports.tz = process.env.MFA_TZ

// comma separated list of domains that are not permitted as recovery email
// addresses, includes subdomains
exports.excluded_domains = process.env.MFA_EXCLUDED_DOMAINS

// the ammount of time to give users to click on email links before they expire
// expressed in seconds or a string describing a time span https://github.com/zeit/ms
exports.links_expire = process.env.MFA_LINKS_EXPIRE

// SMTP server to send emails
exports.smtp_config = {
  host: process.env.MFA_SMTP_HOST,
  port: process.env.MFA_SMTP_PORT,
  secure: false,
  ignoreTLS: true
}

// sender's address
exports.from = process.env.MFA_FROM_EMAIL

// subject for recovery email verification
exports.recovery_verification_subject = process.env.MFA_RECOVERY_SUBJECT

// subject for MFA settings reset verification
exports.reset_verification_subject = process.env.MFA_RESET_SUBJECT

// the domain servers to search through for guids
exports.search_servers = process.env.MFA_SEARCH_SERVERS

// the URL to the support page
exports.support_url = process.env.MFA_SUPPORT_URL
