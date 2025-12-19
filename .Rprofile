# Set local library path for this project
.libPaths(c(file.path(getwd(), ".R", "library"), .libPaths()))

# Create the library directory if it doesn't exist
if (!dir.exists(file.path(getwd(), ".R", "library"))) {
  dir.create(file.path(getwd(), ".R", "library"), recursive = TRUE)
}

cat("Using local R library:", file.path(getwd(), ".R", "library"), "\n") 