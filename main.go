package main

import (
	"fmt"

	"github.com/toozej/golang-starter/math"
)

func main() {
	addMessage := math.Add(1, 2)
	fmt.Println(addMessage)

	subMessage := math.Subtract(2, 2)
	fmt.Println(subMessage)
}
