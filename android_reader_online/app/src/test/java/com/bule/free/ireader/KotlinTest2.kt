package com.bule.free.ireader

import com.google.gson.Gson
import com.google.gson.JsonParser
import org.junit.Test
import kotlin.reflect.KProperty

/**
 * Created by suikajy on 2019/4/12
 */
class KotlinTest2 {


    @Test
    fun test1() {
        history = history + "s"
        history = history + "aa"
        println(history)
    }

    var history by HistoryDelegate()

    class HistoryDelegate {
        private var sp = ""
        val gson = Gson()
        operator fun getValue(thisRef: Any?, property: KProperty<*>): List<String> {
            println("get")
            return try {
                val historyJson = sp
                val jsonArray = JsonParser().parse(historyJson).asJsonArray
                val result = mutableListOf<String>()
                jsonArray.forEach {
                    result += gson.fromJson(it, String::class.java)
                }
                result
            } catch (e: Exception) {
                mutableListOf()
            }
        }

        operator fun setValue(thisRef: Any?, property: KProperty<*>, value: List<String>) {
            val json = Gson().toJson(value)
            println("set string $json")
            sp = json
        }
    }
}
