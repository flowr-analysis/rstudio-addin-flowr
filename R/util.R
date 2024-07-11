find_criterion <- function(row, col, contents) {
  # we iterate backwards through the line until we find the (likely) start of the token
  for (i in col:0) {
    match <- regexpr("[^a-zA-Z0-9._:]+", substring(contents[row], i - 1, i - 1))
    if (attr(match, "match.length") > 0) {
      return(paste0(row, ":", i))
    }
  }
}

visit_nodes <- function(nodes, callback) {
  if (!is.null(nodes)) {
    for (node in nodes) {
      visit_node(node, callback)
    }
  }
}

visit_node <- function(node, callback) {
  if (is.null(node)) {
    return()
  }

  callback(node)

  # same logic as the builtin visitor (while explicitly specifying if an entry is a single node or a list)
  # https://github.com/Code-Inspect/flowr/blob/main/src/r-bridge/lang-4.x/ast/model/processing/visitor.ts#L22
  switch(node$type,
    RFunctionCall = {
      if (node$named) {
        visit_node(node$functionName, callback)
      } else {
        visit_node(node$calledFunction, callback)
      }
      visit_nodes(node$arguments, callback)
    },
    RFunctionDefinition = {
      visit_nodes(node$parameters, callback)
      visit_node(node$body, callback)
    },
    RExpressionList = {
      visit_nodes(node$grouping, callback)
      visit_nodes(node$children, callback)
    },
    RForLoop = {
      visit_node(node$variable, callback)
      visit_node(node$vector, callback)
      visit_node(node$body, callback)
    },
    RWhileLoop = {
      visit_node(node$condition, callback)
      visit_node(node$body, callback)
    },
    RRepeatLoop = {
      visit_node(node$body, callback)
    },
    RIfThenElse = {
      visit_node(node$condition, callback)
      visit_node(node$then, callback)
      visit_node(node$otherwise, callback)
    },
    RBinaryOp = {
      visit_node(node$lhs, callback)
      visit_node(node$rhs, callback)
    },
    RPipe = {
      visit_node(node$lhs, callback)
      visit_node(node$rhs, callback)
    },
    RUnaryOp = {
      visit_node(node$operand, callback)
    },
    RParameter = {
      visit_node(node$name, callback)
      visit_node(node$defaultValue, callback)
    },
    RArgument = {
      visit_node(node$name, callback)
      visit_node(node$value, callback)
    },
    RAccess = {
      visit_node(node$accessed, callback)
      if (node$operator == "[" || node$operator == "[[") {
        visit_nodes(node$access, callback)
      }
    }
  )
}

mark_slice <- function(slice_locations, path, criterion) {
  markers <- list()
  for (location in slice_locations) {
    loc <- location[[1]]
    markers[[length(markers) + 1]] <- list(
      type = "info",
      file = path,
      line = as.numeric(loc[[1]]),
      column = as.numeric(loc[[2]]),
      message = paste0("Member of slice for ", criterion, " (", loc[[1]], ":", loc[[2]], " -> ", loc[[3]], ":", loc[[4]], ")")
    )
  }
  rstudioapi::sourceMarkers("flowr-slice", markers)
  print(paste0("Highlighting ", length(markers), " tokens for slice ", criterion))
}
