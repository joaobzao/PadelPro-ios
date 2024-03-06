package com.joaobzao.padeltuga

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.WindowInsetsSides
import androidx.compose.foundation.layout.consumeWindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.only
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawing
import androidx.compose.foundation.layout.windowInsetsPadding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.CenterAlignedTopAppBar
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.tooling.preview.Preview
import com.joaobzao.padeltuga.ui.theme.PadelTugaTheme

@OptIn(ExperimentalLayoutApi::class, ExperimentalMaterial3Api::class)
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            PadelTugaTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = Color.Transparent
                ) {
                    Scaffold(
                        containerColor = Color.Transparent,
                        contentColor = MaterialTheme.colorScheme.onBackground,
                        contentWindowInsets = WindowInsets(0, 0, 0, 0),
                    ) {
                        Row(
                            Modifier
                                .fillMaxSize()
                                .padding(it)
                                .consumeWindowInsets(it)
                                .windowInsetsPadding(
                                    WindowInsets.safeDrawing.only(
                                        WindowInsetsSides.Horizontal,
                                    )
                                )
                        ) {
                            Column(Modifier.fillMaxSize()) {
                                CenterAlignedTopAppBar(
                                    title = { Text(text = "PadelTuga") },
                                    navigationIcon = {
                                        IconButton(onClick = {  }) {
                                            Icon(
                                                imageVector = Icons.Default.Search,
                                                contentDescription = "navigationIconContentDescription",
                                                tint = MaterialTheme.colorScheme.onSurface,
                                            )
                                        }
                                    },
                                    actions = {
                                        IconButton(onClick = {  }) {
                                            Icon(
                                                imageVector = Icons.Default.Settings,
                                                contentDescription = "actionIconContentDescription",
                                                tint = MaterialTheme.colorScheme.onSurface,
                                            )
                                        }
                                    },
                                    colors = TopAppBarDefaults.centerAlignedTopAppBarColors(
                                        containerColor = Color.Transparent,
                                    )
                                )
                                Greeting("Android")
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    PadelTugaTheme {
        Greeting("Android")
    }
}