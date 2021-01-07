package com.bule.free.ireader

import org.junit.Test

/**
 * Created by suikajy on 2019-05-27
 */

class KotlinTest4 {
    @Test
    fun test() {
        var s: String? = null
        println(s?.subSequence(1..2) == "33")
    }
}