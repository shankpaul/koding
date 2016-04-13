// +build !windows

package tsm1

import "os"

func syncDir(dirName string) error {
	// fsync the dir to flush the rename
	dir, err := os.OpenFile(dirName, os.O_RDONLY, os.ModeDir)
	if err != nil {
		return err
	}
	defer dir.Close()
	return dir.Sync()
}
