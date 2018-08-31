<?php
use \Psr\Http\Message\ServerRequestInterface as Request;
use \Psr\Http\Message\ResponseInterface as Response;

require './vendor/autoload.php';

$config['displayErrorDetails'] = true;
$config['addContentLengthHeader'] = false;

$config['db']['host']   = 'localhost';
$config['db']['user']   = 'hobofo';
$config['db']['pass']   = 'test';
$config['db']['dbname'] = 'hobofo';

$app = new \Slim\App(['settings' => $config]);

$container = $app->getContainer();

$container['logger'] = function($c) {
    $logger = new \Monolog\Logger('my_logger');
    $file_handler = new \Monolog\Handler\StreamHandler('../logs/app.log');
    $logger->pushHandler($file_handler);
    return $logger;
};

$container['db'] = function ($c) {
    $db = $c['settings']['db'];
    $pdo = new PDO('mysql:host=' . $db['host'] . ';dbname=' . $db['dbname'],
        $db['user'], $db['pass']);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    return $pdo;
};

$app->get('/hello/{name}', function (Request $request, Response $response, array $args) {
    $name = $args['name'];
    $response->getBody()->write("Hello, $name");
    $this->logger->addInfo('Response sent..');
    return $response;
});

$app->get('/players/{id}', function (Request $request, Response $response) {
    $this->logger->addInfo("Player by id");
    $player_id = (int)$args['id'];
    $mapper = new PlayerMapper($this->db);
    $player = $mapper->getPlayerById($player_id);

    $response->getBody()->write(var_export($player, true));
    return $response;
});

$app->get('/players', function (Request $request, Response $response) {
    $this->logger->addInfo("Player list");
    $mapper = new PlayerMapper($this->db);
    $players = $mapper->getPlayers();

    // $this->logger->addInfo($players);

    $jsonResponse = $response->withJson($players);
    $corsResponse = $jsonResponse->withHeader('Access-Control-Allow-Origin', '*');
    $corsResponse1 = $corsResponse->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization');
    $corsResponse = $corsResponse1->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
    return $corsResponse;
});

    // Catch-all route to serve a 404 Not Found page if none of the routes match
// NOTE: make sure this route is defined last
$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function($req, $res) {
    $handler = $this->notFoundHandler; // handle using the default Slim page not found handler
    return $handler($req, $res);
});


$app->run();