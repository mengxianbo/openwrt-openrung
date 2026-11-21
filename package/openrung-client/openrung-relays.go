// SPDX-License-Identifier: GPL-3.0-or-later
// Lists the current signed OpenRung relay directory for the OpenWrt LuCI page.
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/openrung/openrung/brokerapi"
	"github.com/openrung/openrung/connectcore"
	"github.com/openrung/openrung/connectcore/discovery"
)

type relayEntry struct {
	ID          string  `json:"id"`
	Label       string  `json:"label,omitempty"`
	City        string  `json:"city,omitempty"`
	Country     string  `json:"country,omitempty"`
	CountryCode string  `json:"country_code,omitempty"`
	Latitude    float64 `json:"latitude,omitempty"`
	Longitude   float64 `json:"longitude,omitempty"`
	NodeClass   string  `json:"node_class,omitempty"`
	Transport   string  `json:"transport,omitempty"`
	ExpiresAt   string  `json:"expires_at,omitempty"`
}

type directory struct {
	FetchedAt string       `json:"fetched_at"`
	Count     int          `json:"count"`
	Relays    []relayEntry `json:"relays"`
}

func main() {
	ctx, cancel := context.WithTimeout(context.Background(), 22*time.Second)
	defer cancel()

	fetch, err := discovery.FirstReachable(ctx, brokerapi.BrokerCandidates(""), discovery.Options{
		Limit:    connectcore.DirectoryRelayLimit,
		Platform: connectcore.PlatformCLI,
	})
	if err != nil {
		fmt.Fprintln(os.Stderr, "OpenRung relay directory:", err)
		os.Exit(1)
	}

	out := directory{
		FetchedAt: time.Now().UTC().Format(time.RFC3339),
		Count:     len(fetch.Response.Relays),
		Relays:    make([]relayEntry, 0, len(fetch.Response.Relays)),
	}
	for _, r := range fetch.Response.Relays {
		out.Relays = append(out.Relays, relayEntry{
			ID:          r.ID,
			Label:       r.Label,
			City:        r.City,
			Country:     r.Country,
			CountryCode: r.CountryCode,
			Latitude:    r.Latitude,
			Longitude:   r.Longitude,
			NodeClass:   r.NodeClass,
			Transport:   r.Transport,
			ExpiresAt:   r.ExpiresAt.UTC().Format(time.RFC3339),
		})
	}

	enc := json.NewEncoder(os.Stdout)
	enc.SetEscapeHTML(true)
	if err := enc.Encode(out); err != nil {
		fmt.Fprintln(os.Stderr, "encode relay directory:", err)
		os.Exit(1)
	}
}
