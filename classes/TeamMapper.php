<?php

class TeamMapper extends Mapper
{
    //id, tournament_id, group_id, player1_id, player2_id
    public function getTeams() {
        $sql = "SELECT * from Teams";
        $stmt = $this->db->query($sql);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }

    /**
     * Get one player by its ID
     *
     * @param int $player_id The ID of the player
     * @return PlayerEntity  The player
     */
    public function getTeamById($team_id) {
        $sql = "SELECT t.id id, t.tournament_id tournament_id, t.group_id group_id, p1.name player1, p1.elo player1_elo, p2.name player2, p2.elo player2_elo
                FROM Teams t
                LEFT JOIN Players p1 ON t.player1_id = p1.id
                LEFT JOIN Players p2 ON t.player2_id = p2.id
                WHERE t.id = :team_id";
        // $sql = "SELECT *
        //     from Teams
        //     where Teams.id = :team_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["team_id" => $team_id]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);

        $team = array(
            'team' => array(
                'id' => $result["id"],
                'tournament_id' => $result["tournament_id"],
                'group_id' => $result["group_id"],
                'players' => array(
                    array('name' => $result["player1"], 'elo' => $result["player1_elo"]),
                    array('name' => $result["player2"], 'elo' => $result["player2_elo"]),
                )
            )
        );

        return $team;
    }

    public function getTeamsByPlayerId($player_id) {
        $sql = "SELECT *
            FROM Teams
            WHERE Teams.player1_id = :player_id OR Teams.player2_id = :player_id ";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["player_id" => $player_id]);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;
    }

    public function save(TicketEntity $ticket) {
        $sql = "insert into tickets
            (title, description, component_id) values
            (:title, :description,
            (select id from components where component = :component))";

        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            "title" => $ticket->getTitle(),
            "description" => $ticket->getDescription(),
            "component" => $ticket->getComponent(),
        ]);

        if(!$result) {
            throw new Exception("could not save record");
        }
    }

    public function saveTeam($teamData) {
        //id, tournament_id, group_id, team1_id, team2_id, team1_score, team2_score, winner_id, matchtype_id, table_id,
        $sql = "INSERT INTO Teams
            (tournament_id, group_id, player1_id, player2_id) values
            (:tournament_id, :group_id, :player1_id, :player2_id)";

        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            "tournament_id" => $teamData["tournament_id"],
            "group_id" => $teamData["group_id"],
            "player1_id" => $teamData["player1_id"],
            "player2_id" => $teamData["player2_id"]
        ]);

        if(!$result) {
            throw new Exception("Could not save team");
        } else {
            return $this->db->lastInsertId();
        }
    }
}