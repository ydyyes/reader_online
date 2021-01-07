package com.bule.free.ireader

import com.google.gson.Gson
import com.google.gson.JsonParser
import com.google.gson.reflect.TypeToken
import org.json.JSONArray
import org.json.JSONObject
import org.junit.Test
import java.lang.reflect.Type
import kotlin.reflect.KProperty

/**
 * Created by suikajy on 2019/4/8
 */
class KotlinTest {

    @Test
    fun test() {
        T.test()
        for (i in 1 until 1) {
            println("i: ${i}")
        }
        println(1 until 0)
    }


    object T {
        init {
            println("init")
        }

        fun test() {
            println("test")
        }
    }

    // 创建接口
    interface Base {
        fun print()
    }

    // 实现此接口的被委托的类
    class BaseImpl(val x: Int) : Base {
        override fun print() {
            print(x)
        }
    }

    // 通过关键字 by 建立委托类
    class Derived : Base by BaseImpl(10)

    @Test
    fun testDelegate() {
        Derived().print()
    }

    @Test
    fun testDel() {
        val example = Example()
        println(example.p)
    }

    @Test
    fun testGson() {
        val gson = Gson()
        val historyJson = "[\"s\",\"a\",\"f\"]"
        val jsonObject = JsonParser().parse(historyJson).asJsonArray
        val result = mutableListOf<String>()
        jsonObject.forEach {
            result += gson.fromJson(it, String::class.java)
        }
        println("result: ${result}")
        val testList = listOf("s", "a", "f")
        println(Gson().toJson(result))
    }

    class Example {
        var p by JsonObjectDelegate()
    }

    class JsonObjectDelegate {
        private var realValue: Int = 0
        operator fun getValue(thisRef: Any?, property: KProperty<*>): Int {
            println("get realValue $realValue")
            return realValue
        }

        operator fun setValue(thisRef: Any?, property: KProperty<*>, value: Int) {
            println("$value has been assigned to '${property.name}' in $thisRef.")
            realValue = value
        }
    }

    @Test
    fun testDelegate2() {
        val example = Example()
        println("--")
        example.p++
        println("example.p: ${example.p}")
        println("--")
    }
}