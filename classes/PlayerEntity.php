<?php

class PlayerEntity
{
    protected $id;
    protected $name;
    protected $phone;
    protected $created;
    protected $active_membership;
    protected $last_paid_membership;
    protected $rating;
    protected $elo;
    protected $receive_sms;

    /**
     * Accept an array of data matching properties of this class
     * and create the class
     *
     * @param array $data The data to use to create
     */
    public function __construct(array $data) {
        // no id if we're creating
        if(isset($data['id'])) {
            $this->id = $data['id'];
        }

        $this->name = $data['name'];
        $this->phone = $data['phone'];

        if(isset($data['created'])) {
            $this->created = $data['created'];
        }

        if(isset($data['active_membership'])) {
            $this->active_membership = $data['active_membership'];
        } else {
            $this->active_membership = false;
        }

        if(isset($data['last_paid_membership'])) {
            $this->last_paid_membership = $data['last_paid_membership'];
        }

        if(isset($data['rating'])) {
            $this->rating = $data['rating'];
        } else {
            $this->rating = 0;
        }

        if(isset($data['elo'])) {
            $this->elo = $data['elo'];
        } else {
            $this->elo = 2000;
        }

        if(isset($data['receive_sms'])) {
            $this->receive_sms = $data['receive_sms'];
        } else {
            $this->receive_sms = true;
        }
    }

    public function getId() {
        return $this->id;
    }

    public function getName() {
        return $this->name;
    }

    public function getPhone() {
        return $this->phone;
    }

    public function getRating() {
        return $this->rating;
    }

    public function getElo() {
        return $this->elo;
    }
}