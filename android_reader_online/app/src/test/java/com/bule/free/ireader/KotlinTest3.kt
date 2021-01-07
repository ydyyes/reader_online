package com.bule.free.ireader

import com.google.gson.Gson
import org.junit.Test

/**
 * Created by suikajy on 2019-04-24
 */
class KotlinTest3 {

    @Test
    fun test() {
        val list = listOf(Bookmark("123", "44.11"), Bookmark("12", "4.11"), Bookmark("125", "44.11"), Bookmark("113", "41.11"))
        println(Gson().toJson(list))
    }

    data class Bookmark(val label: String, val percent: String,val addTime:String = "1231442512")
}