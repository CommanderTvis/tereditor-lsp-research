package com.github.michaelbull.result.on

import com.github.michaelbull.result.Err
import com.github.michaelbull.result.Ok
import com.github.michaelbull.result.Result
import kotlin.test.Test
import kotlin.test.assertEquals

class StudyHiddenMoveTest {

    @Test
    fun onOkAndOnErrLiveInTheOnPackage() {
        val seen = mutableListOf<String>()
        val ok: Result<Int, String> = Ok(1)
        val err: Result<Int, String> = Err("e")

        ok.onOk { seen += "ok $it" }.onErr { seen += "never" }
        err.onOk { seen += "never" }.onErr { seen += "err $it" }

        assertEquals(listOf("ok 1", "err e"), seen)
    }
}
