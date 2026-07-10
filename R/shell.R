# A single flowR session, created lazily and reused across addin invocations.
# All engine handling (starting/locating flowR, protocol, cleanup) lives in the
# `flowr` adapter package; this is only a thin cache with RStudio-friendly
# error handling.

make_flowr_session_storage <- function() {
  session <- NULL

  setHook(packageEvent("rstudioaddinflowr", "onUnload"), function(...) {
    if (!is.null(session)) {
      flowr::flowr_disconnect(session)
      session <<- NULL
    }
  })

  function() {
    if (!is.null(session) && flowr::is_flowr_session(session) && !session$closed) {
      return(session)
    }
    engine <- read_flowr_pref(pref_engine, default_engine)
    flowr_ver <- read_flowr_pref(pref_flowr_version, default_flowr_version)

    connect <- function() {
      flowr::flowr_connect(engine = engine, flowr_version = flowr_ver)
    }
    session <<- tryCatch(connect(), error = function(e) {
      message("[flowR] Could not start the flowR engine: ", conditionMessage(e))
      if (rstudioapi::isAvailable() &&
          rstudioapi::showQuestion(
            "[flowR] Install flowR engine?",
            "No flowR engine is available yet. Set up the flowR engine now?")) {
        tryCatch({
          # install the engine that matches the preference (bundled/auto have no
          # separate installable form, so fall back to the binary) and reconnect
          # with that same engine so the freshly installed one is used
          target <- if (engine %in% c("binary", "node", "docker")) engine else "binary"
          flowr::flowr_install(version = flowr_ver, engine = target)
          flowr::flowr_connect(engine = target, flowr_version = flowr_ver)
        }, error = function(e2) {
          message("[flowR] Installation/connection failed: ", conditionMessage(e2))
          NULL
        })
      } else {
        NULL
      }
    })
    session
  }
}
flowr_session_storage <- make_flowr_session_storage()
