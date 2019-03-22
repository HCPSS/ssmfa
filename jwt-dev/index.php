<?php
// load config
require dirname(dirname(__FILE__)).'/config.php';

// generates the token
use \Firebase\JWT\JWT;

// load authentication
$as = new SimpleSAML_Auth_Simple('default-sp');
// logout if requested
if(isset($_GET['logout'])){
  if($as->isAuthenticated()){
    $as->logout($CFG->logout_target);
  }else{
    header("Location: ".$CFG->logout_target);
    die;
  }
}

// if not authenticated and requesting token send error
if(isset($_REQUEST['token']) and !$as->isAuthenticated()){
  header(http_response_code(401));
  die;
}

// set target urls, pass to SAML so we can get back to where we want
$target = isset($_GET['target']) ? '?target='.$_GET['target'] : '';

// authenticate
$as->requireAuth(
  array('ReturnTo' => $CFG->host_url.$target)
);

// if not requesting token, redirect to target application
if(!isset($_GET['token'])){
  header("Location: ".rawurldecode($_GET['target']));
  die;
}

// get SSO attributes
$attributes = $as->getAttributes();

function send_token($target, $key){
  global $attributes;
  $pattern = "/^".preg_quote($target, "/")."/";
  if(preg_match($pattern, rawurldecode($_GET['target']))){
    // only allow requests from target
    if(!preg_match($pattern, $_SERVER['HTTP_REFERER'])){
      die;
    }
    $token = array(
      "exp" => time() + 600, // expires in 10 minutes
      "iat" => time(),
      "guid" => current($attributes['objectGUID']),
    );
    $jwt = JWT::encode($token, $key, 'RS256');
    echo json_encode($jwt);
    die;
  }
}

// generate token
send_token("SAFE_MFA_BASE_URL", $CFG->key);
