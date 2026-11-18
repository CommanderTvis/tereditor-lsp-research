package io.quarkiverse.httpproblem.postprocessing;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import org.jboss.logging.Logger;
import org.junit.jupiter.api.Test;

class StudyHiddenProblemLogLevelTest {

    @Test
    void warnLogsMessageWithCause() {
        Logger logger = mock(Logger.class);
        when(logger.isEnabled(Logger.Level.WARN)).thenReturn(true);
        Throwable cause = new IllegalStateException("boom");
        ProblemLogLevel.WARN.log(logger, cause, "something failed");
        verify(logger).warn("something failed", cause);
    }

    @Test
    void errorLogsMessageWithCause() {
        Logger logger = mock(Logger.class);
        when(logger.isEnabled(Logger.Level.ERROR)).thenReturn(true);
        Throwable cause = new IllegalStateException("boom");
        ProblemLogLevel.ERROR.log(logger, cause, "something failed");
        verify(logger).error("something failed", cause);
    }

    @Test
    void offLogsNothing() {
        Logger logger = mock(Logger.class);
        ProblemLogLevel.OFF.log(logger, new RuntimeException(), "ignored");
        verify(logger, never()).error(any(Object.class), any(Throwable.class));
    }
}
