<?php

class PlayerMapper extends Mapper
{
    public function getPlayers() {
        $sql = "SELECT p.id, p.name, p.phone, p.rating, p.elo
            FROM Players p
            ORDER BY p.elo DESC";
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
    public function getPlayerById($player_id) {
        $sql = "SELECT p.id, p.name, p.phone, p.rating, p.elo
            from Players p
            where p.id = :player_id";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["player_id" => $player_id]);

        $result = $stmt->fetch(PDO::FETCH_ASSOC);
        return $result;

        // if($result) {
        //     return new PlayerEntity($stmt->fetch());
        // }

    }

    /**
     * Get one player by its phone number
     *
     * @param int $player_phone_number The phone number of the player
     * @return PlayerEntity  The player
     */
    public function getPlayerByPhoneNumber($player_phone_number) {
        $sql = "SELECT p.id, p.name, p.phone, p.rating, p.elo
            from Players p
            where p.phone = :player_phone_number";
        $stmt = $this->db->prepare($sql);
        $stmt->execute(["player_phone_number" => $player_phone_number]);

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