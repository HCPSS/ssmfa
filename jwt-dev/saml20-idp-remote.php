<?php
$metadata['SAFE_MFA_BASE_URL/saml/saml2/idp/metadata.php'] = array (
  'metadata-set' => 'saml20-idp-remote',
  'entityid' => 'SAFE_MFA_BASE_URL/saml/saml2/idp/metadata.php',
  'SingleSignOnService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'SAFE_MFA_BASE_URL/saml/saml2/idp/SSOService.php',
    ),
  ),
  'SingleLogoutService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'SAFE_MFA_BASE_URL/saml/saml2/idp/SingleLogoutService.php',
    ),
  ),
  'certData' => 'CERT_DATA',
  'NameIDFormat' => 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient',
);
