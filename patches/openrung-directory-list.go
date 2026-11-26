// SPDX-License-Identifier: GPL-3.0-or-later

package main

import (
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"time"

	"github.com/openrung/openrung/connectcore"
)

// directoryOutput deliberately exposes only public, signed directory fields.
// Client credentials and transport secrets are never included in this UI API.
type directoryOutput struct {
	FetchedAt time.Time       `json:"fetched_at"`
	Count     int             `json:"count"`
	Relays    []directoryItem `json:"relays"`
}

type directoryItem struct {
	ID         string     `json:"id"`
	Label      string     `json:"label,omitempty"`
	Country    string     `json:"country,omitempty"`
	CountryCode string    `json:"country_code,omitempty"`
	City       string     `json:"city,omitempty"`
	Host       string     `json:"host"`
	Port       int        `json:"port"`
	ProbeMS    *int64     `json:"probe_ms"`
	ExpiresAt  time.Time  `json:"expires_at"`
}

func runList(args []string) error {
	fs := flag.NewFlagSet("list", flag.ContinueOnError)
	if err := fs.Parse(args); err != nil {
		return err
	}
	if fs.NArg() != 0 {
		return fmt.Errorf("list takes no positional arguments")
	}

	engine := connectcore.New()
	ctx, cancel := context.WithTimeout(context.Background(), 45*time.Second)
	defer cancel()

	ranked, err := engine.RankedDirectory(ctx, "")
	if err != nil {
		return fmt.Errorf("fetch relay directory: %w", err)
	}
	out := directoryOutput{
		FetchedAt: time.Now().UTC(),
		Count: len(ranked),
		Relays: make([]directoryItem, 0, len(ranked)),
	}
	for _, item := range ranked {
		r := item.Relay
		out.Relays = append(out.Relays, directoryItem{
			ID: r.ID, Label: r.Label, Country: r.Country,
			CountryCode: r.CountryCode, City: r.City,
			Host: r.PublicHost, Port: r.PublicPort,
			ProbeMS: item.ProbeMS, ExpiresAt: r.ExpiresAt,
		})
	}
	enc := json.NewEncoder(os.Stdout)
	enc.SetIndent("", "  ")
	return enc.Encode(out)
}
