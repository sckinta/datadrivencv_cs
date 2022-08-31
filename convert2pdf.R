# Knit the HTML version
rmarkdown::render("cv_render.Rmd",
                  params = list(pdf_mode = FALSE),
                  output_file = "chun_su_cv.html")

# Knit the PDF version to temporary html location
# use this to replace links with footnotes



pagedown::chrome_print(input = "chun_su_cv.html",
                       output = "chun_su_cv.pdf",
                       verbose = TRUE
                      )