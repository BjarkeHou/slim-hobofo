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
        $sql = "SELECT *
            from Teams
            where Teams.id = :team_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["team_id" => $team_id]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result;
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
}