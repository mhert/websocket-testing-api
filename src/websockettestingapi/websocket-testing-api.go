package main
import (
	"github.com/gorilla/websocket"
	"log"
	"net/http"
)

var httpConectionUpgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool { return true },
}

func handleTest(w http.ResponseWriter, r *http.Request) {
	conn, err := httpConectionUpgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("httpConectionUpgrader.Upgrade: ", err)
		return
	}
	defer conn.Close()

	for {
		mt, message, err := conn.ReadMessage()
		if err != nil {
			log.Println("Conn.ReadMessage: ", err)
			break
		}

		log.Printf("received: %s", message)
		err = conn.WriteMessage(mt, message)
		log.Printf("answered: %s", message)

		if err != nil {
			log.Println("Conn.WriteMessage:", err)
			break
		}
	}
}

func main() {
	http.HandleFunc("/test", handleTest)
	log.Fatal(http.ListenAndServe(":80", nil))
}
