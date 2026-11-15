package com.github.michaelbull.result.coroutines.flow

import com.github.michaelbull.result.Err
import com.github.michaelbull.result.Ok
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.toList
import kotlinx.coroutines.test.runTest
import kotlin.test.Test
import kotlin.test.assertEquals

class StudyHiddenFlowFilterErrTest {

    @Test
    fun flowFilterErrKeepsItsName() = runTest {
        val errors = flowOf(Ok(1), Err("a"), Err("b")).filterErr().toList()

        assertEquals(listOf("a", "b"), errors)
    }
}
