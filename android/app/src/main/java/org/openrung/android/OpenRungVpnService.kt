package org.openrung.android

import android.net.VpnService

/**
 * Android VPN lifecycle entry point.
 *
 * Packet forwarding is intentionally not faked here: a real Android-compatible
 * OpenRung data plane must be integrated before this service can establish a tunnel.
 */
class OpenRungVpnService : VpnService()
