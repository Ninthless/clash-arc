package com.follow.clash.service.models

data class NotificationParams(
    val title: String = "Clash Arc",
    val stopText: String = "STOP",
    val onlyStatisticsProxy: Boolean = false,
)
