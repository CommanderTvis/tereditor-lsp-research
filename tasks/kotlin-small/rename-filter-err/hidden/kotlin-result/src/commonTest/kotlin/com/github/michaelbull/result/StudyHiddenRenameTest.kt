package com.github.michaelbull.result

import kotlin.test.Test
import kotlin.test.assertEquals

class StudyHiddenRenameTest {

    @Test
    fun collectErrReturnsTheErrors() {
        val errors = listOf(Ok(1), Err("a"), Ok(2), Err("b")).collectErr()

        assertEquals(listOf("a", "b"), errors)
    }

    @Test
    fun zipStillCollectsEveryError() {
        val x: Result<Int, String> = Err("x")
        val two: Result<Int, String> = Ok(2)
        val y: Result<Int, String> = Err("y")
        val result = zipOrAccumulate({ x }, { two }, { y }) { a, b, c -> a + b + c }

        assertEquals(Err(listOf("x", "y")), result)
    }
}
