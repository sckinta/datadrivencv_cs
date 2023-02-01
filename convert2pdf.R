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

rmarkdown::render("resume_render.Rmd",
                  params = list(pdf_mode = FALSE),
                  output_file = "resume_render.html")

pagedown::chrome_print(input = "resume_render.html",
                       output = "cs_2page_resume.pdf",
                       verbose = TRUE
)