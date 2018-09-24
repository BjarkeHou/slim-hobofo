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

$app->get('/players/phone{number}', function (Request $request, Response $response) {
    $this->logger->addInfo("Player by phone");
    $player_phone_number = (int)$args['number'];
    $mapper = new PlayerMapper($this->db);
    $player = $mapper->getPlayerByPhoneNumber($player_phone_number);

    return $response
            ->withJson($players)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

$app->get('/players/{id}', function (Request $request, Response $response, $args) {
    $this->logger->addInfo("Player by id");
    $player_id = (int)$args['id'];
    $mapper = new PlayerMapper($this->db);
    $player = $mapper->getPlayerById($player_id);

    return $response
            ->withJson($player)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

$app->get('/players', function (Request $request, Response $response) {
    $this->logger->addInfo("Player list");
    $mapper = new PlayerMapper($this->db);
    $players = $mapper->getPlayers();

    return $response
            ->withJson($players)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

//----------------------------------------------------Matches

$app->get('/matches/player/{id}', function (Request $request, Response $response, $args) {
    $this->logger->addInfo("Match by player id");
    $player_id = (int)$args['id'];
    $mapper = new MatchMapper($this->db);
    $matches = $mapper->getMatchesByPlayerId($player_id);

    return $response
            ->withJson($matches)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});


$app->get('/matches/{id}', function (Request $request, Response $response, $args) {
    $this->logger->addInfo("Match by id");
    $match_id = (int)$args['id'];
    $mapper = new MatchMapper($this->db);
    $match = $mapper->getMatchById($match_id);

    return $response
            ->withJson($match)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

$app->get('/matches', function (Request $request, Response $response) {
    $this->logger->addInfo("Match list");
    $mapper = new MatchMapper($this->db);
    $matches = $mapper->getMatches();

    return $response
            ->withJson($matches)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

//----------------------------------------------------Teams

$app->get('/teams/player/{id}', function (Request $request, Response $response, $args) {
    $this->logger->addInfo("Team by player id");
    $player_id = (int)$args['id'];
    $mapper = new TeamMapper($this->db);
    $teams = $mapper->getTeamsByPlayerId($player_id);

    return $response
            ->withJson($teams)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

$app->get('/teams/{id}', function (Request $request, Response $response, $args) {
    $this->logger->addInfo("Team by id");
    $team_id = (int)$args['id'];
    $mapper = new TeamMapper($this->db);
    $team = $mapper->getTeamById($team_id);

    return $response
            ->withJson($team)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});

$app->get('/teams', function (Request $request, Response $response) {
    $this->logger->addInfo("Team list");
    $mapper = new TeamMapper($this->db);
    $teams = $mapper->getTeams();

    return $response
            ->withJson($teams)
            ->withHeader('Access-Control-Allow-Origin', '*')
            ->withHeader('Access-Control-Allow-Headers', 'X-Requested-With, Content-Type, Accept, Origin, Authorization')
            ->withHeader('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
});



    // Catch-all route to serve a 404 Not Found page if none of the routes match
// NOTE: make sure this route is defined last
$app->map(['GET', 'POST', 'PUT', 'DELETE', 'PATCH'], '/{routes:.+}', function($req, $res) {
    $handler = $this->notFoundHandler; // handle using the default Slim page not found handler
    return $handler($req, $res);
});


$app->run();