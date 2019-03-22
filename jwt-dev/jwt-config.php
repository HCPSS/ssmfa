<?php
// load composer
require dirname(dirname(__FILE__)).'/vendor/autoload.php';

// build and set config object
class Config{}

$CFG = new Config();

$CFG->logdir = '/logs';
$CFG->host_url = 'SAFE_MFA_BASE_URL/sso-jwt/';
$CFG->logout_target = 'SAFE_MFA_BASE_URL';
$CFG->key = file_get_contents('/sso/jwt/jwt.key');
