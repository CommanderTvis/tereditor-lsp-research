package org.jetbrains.kotlinx.dataframe

import io.kotest.matchers.shouldBe
import org.jetbrains.kotlinx.dataframe.api.ParsingConfig
import org.junit.Test
import kotlin.test.assertFailsWith

class StudyHiddenRenameTest {
    @Test
    fun newNameExistsAndOldNameIsGone() {
        ParsingConfig::class.qualifiedName shouldBe "org.jetbrains.kotlinx.dataframe.api.ParsingConfig"
        assertFailsWith<ClassNotFoundException> { Class.forName("org.jetbrains.kotlinx.dataframe.api." + "Parser" + "Options") }
    }
}
