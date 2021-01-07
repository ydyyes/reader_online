package com.bule.free.ireader.common.sharepref

import android.content.Context
import kotlin.properties.ReadWriteProperty
import kotlin.reflect.KProperty

/**
 * Created by suikajy on 2019/4/15
 */
open class SpDel<T>(private val context: Context,
               private val spFileName: String,
               private val key: String,
               private val defaultValue: T) : ReadWriteProperty<Any?, T> {

    private val sp by lazy { context.getSharedPreferences(spFileName, Context.MODE_PRIVATE) }

    override fun getValue(thisRef: Any?, property: KProperty<*>) = findPreference(key, defaultValue)

    override fun setValue(thisRef: Any?, property: KProperty<*>, value: T) = putPreference(key, value)

    private fun <T> findPreference(name: String, default: T): T = with(sp) {
        val res: Any = when (default) {
            is Long -> getLong(name, default)
            is String -> getString(name, default)
            is Int -> getInt(name, default)
            is Boolean -> getBoolean(name, default)
            is Float -> getFloat(name, default)
            else -> throw IllegalArgumentException("This type can not be saved into Preferences")
        }
        res as T
    }

    private fun <U> putPreference(name: String, value: U) = with(sp.edit()) {
        when (value) {
            is Long -> putLong(name, value)
            is String -> putString(name, value)
            is Int -> putInt(name, value)
            is Boolean -> putBoolean(name, value)
            is Float -> putFloat(name, value)
            else -> throw IllegalArgumentException("This type can not be saved into Preferences")
        }.apply()
    }
}