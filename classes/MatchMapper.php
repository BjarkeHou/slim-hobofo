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

    public function saveQuickMatch($matchData) {
        //id, tournament_id, group_id, team1_id, team2_id, team1_score, team2_score, winner_id, matchtype_id, table_id,
        $sql = "insert into matches
            (tournament_id, group_id, team1_id, team2_id, winner_id, matchtype_id, ended) values
            (:tournament_id, :group_id, :team1_id, :team2_id, :winner_id, :matchtype_id, NOW())";

        $stmt = $this->db->prepare($sql);
        $result = $stmt->execute([
            "tournament_id" => -1,
            "group_id" => -1,
            "team1_id" => $matchData["team1_id"],
            "team2_id" => $matchData["team2_id"],
            "winner_id" => $matchData["winner_id"],
            "matchtype_id" => $matchData["matchtype_id"]
        ]);

        if(!$result) {
            throw new Exception("Could not save quickmatch");
        }
    }
}