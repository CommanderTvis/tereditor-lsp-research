package com.embabel.agent.spi.support

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertThrows
import org.junit.jupiter.api.Test

class StudyHiddenMoveTest {
    @Test
    fun movedClassIsOnlyInTheNewPackage() {
        assertEquals("com.embabel.agent.spi.support.ChatModelCallEvent", ChatModelCallEvent::class.java.name)
        assertThrows(ClassNotFoundException::class.java) {
            Class.forName("com.embabel.agent.spi.support." + "springai.ChatModelCallEvent")
        }
    }
}
