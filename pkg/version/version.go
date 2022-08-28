package version

import (
	"encoding/json"
	"fmt"

	"github.com/spf13/cobra"
)

// Version information. These will be filled in by the compiler.
var (
	Version = "local"
	Commit  = ""
	Branch  = ""
	BuiltAt = ""
	Builder = ""
)

// Info holds build information
type Info struct {
	Commit  string
	Version string
	BuiltAt string
}

// Get creates an initialized Info object
func Get() Info {
	return Info{
		Commit:  Commit,
		Version: Version,
		BuiltAt: BuiltAt,
	}
}

// Command creates version command
func Command() *cobra.Command {
	return &cobra.Command{
		Use:   "version",
		Short: "Print the version.",
		Long:  `Print the version and build information.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			info := Get()
			json, err := json.Marshal(info)
			if err != nil {
				return err
			}
			fmt.Println(string(json))

			return nil
		},
	}
}