package org.openrung.android

import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            var proxyType by remember { mutableStateOf("HTTP") }
            var port by remember { mutableStateOf("44025") }
            MaterialTheme {
                Column(
                    modifier = Modifier.fillMaxSize().padding(24.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    Text("OpenRung", style = MaterialTheme.typography.headlineMedium)
                    Text("Android 本地代理")
                    Text("代理类型：$proxyType")
                    androidx.compose.foundation.layout.Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                        Button(onClick = { proxyType = "HTTP" }) { Text("HTTP") }
                        Button(onClick = { proxyType = "SOCKS5" }) { Text("SOCKS5") }
                    }
                    Text("本地监听端口：$port")
                    Text("监听地址：127.0.0.1")
                    Text("状态：核心引擎尚未集成")
                    Button(onClick = { /* Enabled after the Android proxy engine is integrated. */ }, enabled = false) {
                        Text("启动代理（待接入核心）")
                    }
                    Text("仅提供本地代理，不申请 VPN 权限，不接管其他应用流量。")
                }
            }
        }
    }
}
