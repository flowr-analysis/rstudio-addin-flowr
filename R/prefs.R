pref_node_version <- "node_version"
pref_flowr_version <- "flowr_version"
pref_server_host <- "localhost"
pref_server_port <- 1042
pref_light_theme <- "light_theme"
pref_dark_theme <- "dark_theme"

default_node_version <- "22.5.1"
default_flowr_version <- "2.0.11"
default_light_theme <- "github"
default_dark_theme <- "github-dark-dimmed"

write_flowr_pref <- function(name, value) {
  rstudioapi::writePreference(paste0("flowr.", name), value)
}

read_flowr_pref <- function(name, default) {
  return(rstudioapi::readPreference(paste0("flowr.", name), default))
}
