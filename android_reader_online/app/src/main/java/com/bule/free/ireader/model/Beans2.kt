package com.bule.free.ireader.model

/**
 * Created by suikajy on 2019/3/22
 *
 * 2.0接口bean
 */

data class MissionBean2(
        val describe: String,
        val id: String,
        val name: String,
        val num: String,
        val task_type: String,
        val type: String
)

data class SignGoldBean(
        val value: Int,
        val comment: String
)

data class MissionPostBean(
        val num: Int = 0,
        val total: String = "",
        val res: Boolean = false
)

data class GoldExchangeItemBean(
        val cost_gold: String,
        val id: String,
        val name: String,
        val num: String,
        val type: String,
        val cover: String
)

data class GoldRecordBean(
        val create_time: String,
        val describe: String,
        val eid: String,
        val etype: String,
        val id: String,
        val name: String,
        val num: String
)

data class MissionInitDataBean(
        val NOW_USER_SIGN: Int,// 1:已经签到 0 :未签到
        val AD_BROWSE_LIMIT: Int,
        val AD_BROWSE_LIMIT_NUM: Int,
        val AD_REDARER_LIMIT: Int,
        val AD_REDARER_LIMIT_NUM: Int,
        val SHARE_TIMES_LIMIT: Int,
        val SHARE_TIMES_LIMIT_NUM: Int,
        val SIGN_CURRNT_NUM: Int,
        val SIGN_TOTAL_NUM: Int
)

data class InviteFriItemBean(
        val create_time: String,
        val id: String,
        val pa_mobile: String
)