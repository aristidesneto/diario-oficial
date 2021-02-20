<?php
// Abre arquivo com as dastas disponiveis para download
$File = fopen('./logs/datas.txt', 'r');
?>
<!doctype html>
<html lang="pt-br">
<head>
	<meta charset="utf-8">
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<meta name="description" content="Download Diário Oficial">
	<meta name="author" content="Aristides Neto">
	<title>Download Diário Oficial</title>

	<!-- Bootstrap core CSS -->
	<link href="./css/bootstrap.min.css" rel="stylesheet">

	<!-- Custom styles for this template -->
	<link href="./css/pricing.css" rel="stylesheet">
</head>

<body>

	<!-- <div class="d-flex flex-column flex-md-row align-items-center p-3 px-md-4 mb-3 bg-white border-bottom box-shadow">
        <h5 class="my-0 mr-md-auto font-weight-normal">Aristides Neto</h5>
        <nav class="my-2 my-md-0 mr-md-3">
            <a class="p-2 text-dark" href="#">Features</a>
            <a class="p-2 text-dark" href="#">Enterprise</a>
            <a class="p-2 text-dark" href="#">Support</a>
            <a class="p-2 text-dark" href="#">Pricing</a>
        </nav>
        <a class="btn btn-outline-primary" href="#">Sign up</a>
	</div> -->

	<div class="pricing-header px-3 py-3 pt-md-4 pb-md-4 mx-auto text-center">
        <h1 class="display-4">Diário Oficial</h1>
        <p class="lead">Download do arquivo completo do Diário Oficial do Estado de São Paulo.</p>
        <p><strong>Atualizado diariamente às 7:30</strong></p>
	</div>

	<div class="container text-center">
		
        <table class="table table-hover table-responsive-md table-sm">
            <thead>
                <tr>
                    <th>Data</th>
                    <th>Caderno</th>
                    <th>Opção</th>
                </tr>
            </thead>
            <tbody>
                <?php   
                    while (($linha = fgets($File)) !== false)
                    {                                              
                        $Arr = explode(';', $linha);                        
                        ?>
                        <tr>
                            <td class="pt-md-3"><?= $Arr[0] ?></td>
                            <td class="pt-md-3"><?= $Arr[1] ?></td>
                            <td class="pt-md-3"><a href="./files/<?= $Arr[2] ?>" target="_blank" title="Download Arquivo" >Download (<?= trim($Arr[3]) ?>)</a></td>
                        </tr>
                        <?php
                    }                    
                ?>
            </tbody>
        </table>
	
        <footer class="pt-4 my-md-5 pt-md-3 border-top text-muted">
            <div class="row">
                <div class="col-12 col-md">
                    <small class="d-block">
                        &copy; 2018 - Todos os direitos reservados.<br>Desenvolvido por <a href="https://www.aristidesneto.com.br" target="_blank" title="Ir para Aristides Neto" >Aristides Neto</a>
                    </small>
                </div>
                            
            </div>
        </footer>
	</div>

    <?php
    fclose($File);
    ?>


	<!-- Bootstrap core JavaScript
	================================================== -->
	<!-- Placed at the end of the document so the pages load faster -->
	<script src="https://code.jquery.com/jquery-3.2.1.slim.min.js"></script>
	<script src="./js/bootstrap.min.js"></script>

</body>
</html>
