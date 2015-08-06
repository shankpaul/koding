package main

import (
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/koding/kite"
)

type VmController struct {
	Redis  *RedisStorage
	Klient *kite.Client
	Aws    *credentials.Credentials
}
