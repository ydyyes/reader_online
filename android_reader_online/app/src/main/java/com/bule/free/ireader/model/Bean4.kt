package com.bule.free.ireader.model

/**
 * Created by suikajy on 2019-06-03
 */

data class AdvListBean(
    val cover: String,
    val id: String,
    val link: String,
    val location: String,
    val title: String
)

data class OpenningDialogBean(
    val info: Info,
    val res_status: Boolean
)

data class Info(
    val cover: String,
    val id: String,
    val link: String,
    val location: String,
    val start_time: String,
    val title: String
)