<?php
// Looking for the default values set? See: https://github.com/roundcube/roundcubemail/blob/master/config/defaults.inc.php
$config = array();
$config['product_name'] = 'MailTrap Roundcube';
$config['db_dsnw'] = 'sqlite:////var/lib/roundcube/db/sqlite.db';
$config['des_key'] = '###DES_KEY###';
$config['plugins'] = array(
    'archive',
    'zipdownload',
    'contextmenu',
    'keyboard-shortcuts',
    'message-highlight',
    'enigma',
    'emoticons',
);
$config['session_lifetime'] = 1440;
$config['message_show_email'] = true;
$config['protect_default_folders'] = true;
//$config['disabled_actions'] = array('addressbook.index','mail.compose','mail.reply','mail.reply-all','mail.forward');
$config['skin'] = 'larry';