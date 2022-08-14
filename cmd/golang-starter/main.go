package main

import (
	"fmt"

	"github.com/toozej/golang-starter/cmd/golang-starter/config"
	"github.com/toozej/golang-starter/cmd/golang-starter/math"
)

func main() {
	// load application configurations
	if err := config.LoadConfig("./config"); err != nil {
		panic(fmt.Errorf("invalid application configuration: %s", err))
	}

	fmt.Println(config.Config.ConfigVar)

	addMessage := math.Add(1, 2)
	fmt.Println(addMessage)

	subMessage := math.Subtract(2, 2)
	fmt.Println(subMessage)
}
