package com.embabel.plan

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Test

class StudyHiddenSignatureTest {
    @Test
    fun planToGoalTakesTheGoalFirst() {
        val m = Planner::class.java.methods.single { it.name == "planToGoal" }
        assertEquals(listOf(Goal::class.java, Collection::class.java), m.parameterTypes.toList())
    }
}
