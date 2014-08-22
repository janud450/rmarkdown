
#' Convert to a slidy presentation
#' 
#' Format for converting from R Markdown to a slidy presentation.
#' 
#' @inheritParams beamer_presentation
#' @inheritParams pdf_document
#' @inheritParams html_document
#'   
#' @param duration Duration (in minutes) of the slide deck. This value is used
#'   to add a countdown timer to the slide footer.  
#' @param footer Footer text (e.g. organization name and/or copyright)
#' @param font_adjustment Increase or decrease the default font size
#'  (e.g. -1 or +1). You can also manually adjust the font size during the
#'  presentation using the 'S' (smaller) and 'B' (bigger) keys.
#' 
#' @return R Markdown output format to pass to \code{\link{render}}
#'   
#' @details
#' 
#' For more information on markdown syntax for presentations see 
#' \href{http://johnmacfarlane.net/pandoc/demo/example9/producing-slide-shows-with-pandoc.html}{producing
#' slide shows with pandoc}.
#' 
#' @examples
#' \dontrun{
#' 
#' library(rmarkdown)
#' 
#' # simple invocation
#' render("pres.Rmd", slidy_presentation())
#' 
#' # specify an option for incremental rendering
#' render("pres.Rmd", slidy_presentation(incremental = TRUE))
#' }
#' 
#' @export
slidy_presentation <- function(incremental = FALSE,
                               duration = NULL,
                               footer = NULL,
                               font_adjustment = 0,
                               fig_width = 8,
                               fig_height = 6,
                               fig_retina = if (!fig_caption) 2,
                               fig_caption = FALSE,
                               smart = TRUE,
                               self_contained = TRUE,
                               highlight = "default",
                               mathjax = "default",
                               template = "default",
                               css = NULL,
                               includes = NULL,
                               keep_md = FALSE,
                               lib_dir = NULL,
                               pandoc_args = NULL,
                               ...) {

  # base pandoc options for all reveal.js output
  args <- c()

  # template path and assets
  if (identical(template, "default"))
    args <- c(args, "--template",
              pandoc_path_arg(rmarkdown_system_file(
                "rmd/slidy/default.html")))
  else if (!is.null(template))
    args <- c(args, "--template", pandoc_path_arg(template))

  # incremental
  if (incremental)
    args <- c(args, "--incremental")
  
  # duration
  if (!is.null(duration))
    args <- c(args, pandoc_variable_arg("duration", duration))
  
  # footer
  if (!is.null(footer))
    args <- c(args, pandoc_variable_arg("footer", footer))

  # font size adjustment
  if (font_adjustment != 0)
    args <- c(args, pandoc_variable_arg("font-size-adjustment", 
                                        font_adjustment))
  
  # content includes
  args <- c(args, includes_to_pandoc_args(includes))

  # additional css
  for (css_file in css)
    args <- c(args, "--css", pandoc_path_arg(css_file))
  
  # pre-processor for arguments that may depend on the name of the
  # the input file (e.g. ones that need to copy supporting files)
  pre_processor <- function(metadata, input_file, runtime, knit_meta, files_dir,
                            output_dir) {

    # use files_dir as lib_dir if not explicitly specified
    if (is.null(lib_dir))
      lib_dir <- files_dir

    # extra args
    args <- c()

    # slidy
    slidy_path <- rmarkdown_system_file("rmd/slidy/Slidy2")
    if (!self_contained || is_windows())
      slidy_path <- relative_to(
        output_dir, render_supporting_files(slidy_path, lib_dir))
    args <- c(args, "--variable", paste("slidy-url=",
                                        pandoc_path_arg(slidy_path), sep=""))

    # highlight
    args <- c(args, pandoc_highlight_args(highlight, default = "pygments"))

    # return additional args
    args
  }

  # return format
  output_format(
    knitr = knitr_options_html(fig_width, fig_height, fig_retina, keep_md),
    pandoc = pandoc_options(to = "slidy",
                            from = from_rmarkdown(fig_caption),
                            args = args),
    keep_md = keep_md,
    clean_supporting = self_contained,
    pre_processor = pre_processor,
    base_format = html_document_base(smart = smart, lib_dir = lib_dir,
                                     self_contained = self_contained,
                                     mathjax = mathjax,
                                     bootstrap_compatible = TRUE, 
                                     pandoc_args = pandoc_args, ...))
}