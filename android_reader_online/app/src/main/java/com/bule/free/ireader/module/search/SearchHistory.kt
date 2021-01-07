package com.bule.free.ireader.module.search

import android.content.Context
import com.bule.free.ireader.App
import com.google.gson.Gson
import com.google.gson.JsonParser
import kotlin.reflect.KProperty

/**
 * Created by suikajy on 2019/4/11
 */
object SearchHistory {

    private const val KEY_SEARCH_CACHE = "search_cache"
    private const val MAX_HISTORY_COUNT = 6

    private val sp = App.instance.getSharedPreferences("SearchHistory", Context.MODE_PRIVATE)
    private val gson = Gson()
    private var historyList by HistoryDelegate()

    fun addHistory(keyword: String) {
        if (keyword.isEmpty()) return
        val oldList = historyList
        val newList = mutableListOf<String>()
        if (keyword in oldList) {
            newList.addAll(oldList)
            newList.remove(keyword)
            newList.add(0, keyword)
        } else {
            newList.addAll(oldList)
            newList.add(0, keyword)
        }
        historyList = newList.take(MAX_HISTORY_COUNT)
    }

    fun getHistory() = historyList

    fun clear() {
        historyList = emptyList()
    }

    private class HistoryDelegate {
        operator fun getValue(thisRef: Any?, property: KProperty<*>): List<String> {
            return try {
                val historyJson = sp.getString(KEY_SEARCH_CACHE, "")
                val jsonArray = JsonParser().parse(historyJson).asJsonArray
                val result = mutableListOf<String>()
                jsonArray.forEach {
                    result += gson.fromJson(it, String::class.java)
                }
                result
            } catch (e: Exception) {
                emptyList()
            }
        }

        operator fun setValue(thisRef: Any?, property: KProperty<*>, value: List<String>) {
            val json = Gson().toJson(value)
            sp.edit().putString(KEY_SEARCH_CACHE, json).apply()
        }
    }
}