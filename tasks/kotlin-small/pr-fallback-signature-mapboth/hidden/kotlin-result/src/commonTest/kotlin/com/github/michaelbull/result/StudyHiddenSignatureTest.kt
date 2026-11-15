package com.github.michaelbull.result

import kotlin.test.Test
import kotlin.test.assertEquals

class StudyHiddenSignatureTest {

    private val ok: Result<Int, Long> = Ok(50)
    private val err: Result<Int, Long> = Err(20L)

    @Test
    fun mapBothTakesTheFailureFunctionFirst() {
        assertEquals("good 50", ok.mapBoth({ e: Long -> "bad $e" }, { v: Int -> "good $v" }))
        assertEquals("bad 20", err.mapBoth({ e: Long -> "bad $e" }, { v: Int -> "good $v" }))
    }

    @Test
    fun namedArgumentsStillWork() {
        assertEquals("good 50", ok.mapBoth(success = { "good $it" }, failure = { "bad $it" }))
    }

    @Test
    fun foldKeepsItsOrder() {
        assertEquals("good 50", ok.fold({ v: Int -> "good $v" }, { e: Long -> "bad $e" }))
        assertEquals("bad 20", err.fold({ v: Int -> "good $v" }, { e: Long -> "bad $e" }))
    }
}
