package io.quarkiverse.httpproblem;

import static org.assertj.core.api.Assertions.assertThat;

import org.junit.jupiter.api.Test;

import io.quarkiverse.httpproblem.postprocessing.ProblemContext;

class StudyHiddenMoveTest {

    @Test
    void postProcessorLivesInTheRootPackage() {
        ProblemPostProcessor processor = (problem, context) -> problem;
        HttpProblem problem = HttpProblem.builder().withStatus(400).build();
        assertThat(processor.apply(problem, ProblemContext.of(new RuntimeException(), (String) null))).isSameAs(problem);
        assertThat(ProblemPostProcessor.class.getName()).isEqualTo("io.quarkiverse.httpproblem.ProblemPostProcessor");
    }
}
