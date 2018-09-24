<?php

class MatchMapper extends Mapper
{
    //id, tournament_id, group_id, team1_id, team2_id, team1_score, team2_score, winner_id, matchtype_id, table_id,
    public function getMatches() {
        $sql = "SELECT * from Matches";
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
    public function getMatchById($match_id) {
        $sql = "SELECT *
            from Matches
            where Matches.id = :match_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["match_id" => $match_id]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result;

        // if($result) {
        //     return new PlayerEntity($stmt->fetch());
        // }
    }

    public function getMatchesByPlayerId($player_id) {
        // Find all matches from teams where playerid is on.
        $sql = "SELECT * FROM Matches
            WHERE team1_id IN (SELECT t.id FROM Teams t WHERE t.player1_id = :player_id OR t.player2_id = :player_id)
            OR team2_id IN (SELECT t.id FROM Teams t WHERE t.player1_id = :player_id OR t.player2_id = :player_id)";
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