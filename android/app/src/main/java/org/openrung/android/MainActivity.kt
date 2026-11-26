package org.openrung.android

import android.app.Activity
import android.content.Intent
import android.net.VpnService
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.RadioButton
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var mode by remember { mutableStateOf("Local proxy") }
            MaterialTheme {
                Column(
                    modifier = Modifier.fillMaxSize().padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp),
                    horizontalAlignment = Alignment.Start
                ) {
                    Text("OpenRung", style = MaterialTheme.typography.headlineMedium)
                    Text("Android client · development preview")
                    RowChoice("Local HTTP / SOCKS5 proxy", mode == "Local proxy") { mode = "Local proxy" }
                    RowChoice("Device-wide VPN", mode == "VPN") { mode = "VPN" }
                    Text("Selected mode: $mode")
                    Button(onClick = {
                        if (mode == "VPN") {
                            val intent = VpnService.prepare(this@MainActivity)
                            if (intent != null) startActivityForResult(intent, 1001)
                        }
                    }) { Text(if (mode == "VPN") "Request VPN permission" else "Local proxy: core integration pending") }
                    Text("This preview does not establish a proxy connection yet.")
                }
            }
        }
    }

    @Deprecated("Use Activity Result APIs in the production connection flow")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == 1001 && resultCode == Activity.RESULT_OK) {
            // Permission granted only. The Android data plane is not integrated yet.
        }
    }
}

@Composable
private fun RowChoice(label: String, selected: Boolean, onSelect: () -> Unit) {
    androidx.compose.foundation.layout.Row(verticalAlignment = Alignment.CenterVertically) {
        RadioButton(selected = selected, onClick = onSelect)
        Text(label)
    }
}
