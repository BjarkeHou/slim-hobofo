import json
import mysql.connector
from io import open

if __name__ == '__main__':
	cnx = mysql.connector.connect(user='hobofo', password='test',
                              host='localhost',
                              database='hobofo')
	cursor = cnx.cursor()
	add_player = ("INSERT INTO Players "
                 "(name, phone, elo) "
                 "VALUES (%s, %s, %s)")

	OldMax = 8000;
	OldMin = 0;
	NewMax = 700;
	NewMin = -100;
	OldRange = (OldMax - OldMin)
	NewRange = (NewMax - NewMin)

	with open("hbf_rangliste.json", "r") as f:
		json_string = f.read()

		players = json.loads(json_string)

		for player in players:
			print(json.dumps(player))
			player_data = (player["navn"], player["telefon"], 1200+(((player["avg"] - OldMin) * NewRange) / OldRange) + NewMin)
			cursor.execute(add_player, player_data)

	cnx.commit()
	cursor.close()
	cnx.close()