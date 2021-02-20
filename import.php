<?php

// $Data = date('d-m-Y');
$Data = '09-07-2018';

$filename = "./logs/do_caderno1_".$Data.".txt";

if (file_exists($filename)) {
    echo "O arquivo $filename existe";
} else {
    $output = shell_exec("./shell/diario.sh"); 
    echo "<pre>$output</pre>"; 
}

