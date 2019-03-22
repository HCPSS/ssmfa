<?php
$metadata['SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/metadata.php/default-sp'] = array (
  'SingleLogoutService' =>
  array (
    0 =>
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/saml2-logout.php/default-sp',
    ),
  ),
  'AssertionConsumerService' =>
  array (
    0 =>
    array (
      'index' => 0,
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/saml2-acs.php/default-sp',
    ),
    1 =>
    array (
      'index' => 1,
      'Binding' => 'urn:oasis:names:tc:SAML:1.0:profiles:browser-post',
      'Location' => 'SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/saml1-acs.php/default-sp',
    ),
    2 =>
    array (
      'index' => 2,
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact',
      'Location' => 'SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/saml2-acs.php/default-sp',
    ),
    3 =>
    array (
      'index' => 3,
      'Binding' => 'urn:oasis:names:tc:SAML:1.0:profiles:artifact-01',
      'Location' => 'SAFE_MFA_BASE_URL/sso-jwt/samlsp/module.php/saml/sp/saml1-acs.php/default-sp/artifact',
    ),
  ),
  'authproc' => array(
    10 => array(
      'class' => 'core:PHP',
      'code' => '
        function fromBase64($base64guid){
          return fromBin(base64_decode($base64guid));
        }
        function littleEndian($hex) {
          $result = "";
          for ($x=strlen($hex)-2; $x >= 0; $x=$x-2) {
            $result .= substr($hex,$x,2);
          }
          return $result;
        }
        function fromBin($binguid){
          $hex_guid=bin2hex($binguid);
          $one = littleEndian(substr($hex_guid,0,8));    // Get revision-part of SID
          $two = littleEndian(substr($hex_guid,8,4));    // Get count of sub-auth entries
          $three = littleEndian(substr($hex_guid,12,4)); // SECURITY_NT_AUTHORITY
          $four = substr($hex_guid,16,4);                // SECURITY_NT_AUTHORITY
          $five = substr($hex_guid,20,12);               // SECURITY_NT_AUTHORITY
          return strtolower("$one-$two-$three-$four-$five");
        }
        if(isset($attributes["objectGUID"])){
          $attributes["objectGUID"] = array(fromBase64(current($attributes["objectGUID"])));
        }
      '
    ),
  ),
);
