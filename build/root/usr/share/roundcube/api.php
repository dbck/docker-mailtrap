<?php
# Credits to https://electrictoolbox.com/php-imap-message-body-attachments/ which has described
# the implementation details to read message from an imap mailbox.

function flattenParts($messageParts, $flattenedParts = array(), $prefix = '', $index = 1, $fullPrefix = true) {

  foreach($messageParts as $part) {
    $flattenedParts[$prefix.$index] = $part;
    if(isset($part->parts)) {
      if($part->type == 2) {
        $flattenedParts = flattenParts($part->parts, $flattenedParts, $prefix.$index.'.', 0, false);
      }
      elseif($fullPrefix) {
        $flattenedParts = flattenParts($part->parts, $flattenedParts, $prefix.$index.'.');
      }
      else {
        $flattenedParts = flattenParts($part->parts, $flattenedParts, $prefix);
      }
      unset($flattenedParts[$prefix.$index]->parts);
    }
    $index++;
  }

  return $flattenedParts;

}

function getPart($connection, $messageNumber, $partNumber, $encoding) {

  $data = imap_fetchbody($connection, $messageNumber, $partNumber);
  switch($encoding) {
    case 0: return $data; // 7BIT
    case 1: return $data; // 8BIT
    case 2: return $data; // BINARY
    case 3: return base64_decode($data); // BASE64
    case 4: return quoted_printable_decode($data); // QUOTED_PRINTABLE
    case 5: return $data; // OTHER
    default: break;
  }
}

function getFilenameFromPart($part) {
  $filename = '';

  if($part->ifdparameters) {
    foreach($part->dparameters as $object) {
      if(strtolower($object->attribute) == 'filename') {
        $filename = $object->value;
      }
    }
  }

  if(!$filename && $part->ifparameters) {
    foreach($part->parameters as $object) {
      if(strtolower($object->attribute) == 'name') {
        $filename = $object->value;
      }
    }
  }

  return $filename;
}
$data=array();
$server="{localhost:143/novalidate-cert}";
$login="###MAILTRAP_USER###";
$password="###MAILTRAP_PASSWORD###";
$connection = imap_open($server, $login, $password);
$messageCount = imap_num_msg($connection);

for($messageNumber = 1; $messageNumber <= $messageCount; $messageNumber++) {
  $headers = imap_headerinfo($connection, $messageNumber);
  #echo '<pre>' . print_r($headers) . '</pre>';

  $mail = new stdClass();
  $mail->message_id=$headers->message_id;
  $mail->date=$headers->date;
  $mail->subject=$headers->subject;
  $mail->from=array();
  if(isset($headers->from)) {
    foreach($headers->from as $val) {
      $from = new stdClass();
      $from->name=$val->personal;
      $from->address=$val->mailbox."@".$val->host;
      array_push($mail->from,$from);
    }
  }
  $mail->to=array();
  if(isset($headers->to)) {
    foreach($headers->to as $val) {
      $obj = new stdClass();
      $obj->name=isset($val->personal) ? $val->personal : null;
      $obj->address=$val->mailbox."@".$val->host;
      array_push($mail->to,$obj);
    }
  }
  $mail->cc=array();
  if(isset($headers->cc)) {
    foreach($headers->cc as $val) {
      $obj = new stdClass();
      $obj->name=isset($val->personal) ? $val->personal : null;
      $obj->address=$val->mailbox."@".$val->host;
      array_push($mail->cc,$obj);
    }
  }
  $mail->reply_to=array();
  if(isset($headers->reply_to)) {
    foreach($headers->reply_to as $val) {
      $obj = new stdClass();
      $obj->name=isset($val->personal) ? $val->personal : null;
      $obj->address=$val->mailbox."@".$val->host;
      array_push($mail->reply_to,$obj);
    }
  }
  $mail->attachments=array();
  array_push($data,$mail);
  $structure = imap_fetchstructure($connection, $messageNumber);
  $flattenedParts = flattenParts($structure->parts);
  foreach($flattenedParts as $partNumber => $part) {
    switch($part->type) {
      case 0:
        $message = getPart($connection, $messageNumber, $partNumber, $part->encoding);
        $mail->message=$message;
        break;
      case 1: // multi-part headers, can ignore
        break;
      case 2: // attached message headers, can ignore
        break;
      case 3: // application
      case 4: // audio
      case 5: // image
      case 6: // video
      case 7: // other
        $file = new stdClass();
        $file->filename=getFilenameFromPart($part);
        if($file->filename && $_GET["include_data"] == "true") {
          $file->data = getPart($connection, $messageNumber, $partNumber, $part->encoding);
        }
        else {
          // don't know what it is
        }
        array_push($mail->attachments,$file);
        break;
      default:
        break;
    }
  }
}

if ($_GET["flush"] == "true") {
  $messageCount = imap_num_msg($connection);
  for($messageNumber = 1; $messageNumber <= $messageCount; $messageNumber++) {
    imap_delete($connection, $messageNumber);
  }
  imap_expunge($connection);
}

imap_close($connection);

header('Content-Type: application/json');
echo json_encode($data);
?>