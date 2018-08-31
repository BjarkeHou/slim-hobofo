<?php

class PlayerMapper extends Mapper
{
    public function getPlayers() {
        $sql = "SELECT p.id, p.name, p.phone, p.rating, p.elo
            from Players p";
        $stmt = $this->db->query($sql);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $result;

        // $results = [];
        // while($row = $stmt->fetch()) {
        //     $results[] = new PlayerEntity($row);
        // }
        // return $results;
    }

    /**
     * Get one player by its ID
     *
     * @param int $player_id The ID of the player
     * @return PlayerEntity  The player
     */
    public function getPlayerById($player_id) {
        $sql = "SELECT p.id, p.name, p.phone, p.rating, p.elo
            from Players p
            where p.id = :player_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["player_id" => $player_id]);

        $result = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return json_encode($result);

        // if($result) {
        //     return new PlayerEntity($stmt->fetch());
        // }

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