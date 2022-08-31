# path <- "https://docs.google.com/spreadsheets/d/1dcd31plt_SmlHMWiNDiXHgFcJIHdhPyGVORvgCt5EMk/edit?usp=sharing"

create_cv_obj <- function(path, public = F){
    is_google_sheets_location <- stringr::str_detect(path, "docs\\.google\\.com")
    
    cv <- list()
    
    if(is_google_sheets_location){
        if(public){
            googlesheets4::gs4_deauth() # If you don’t need to access private Sheets, use gs4_deauth() to indicate there is no need for a token
        }else{
            googlesheets4::gs4_auth()
        }
        cv$entries <- googlesheets4::read_sheet(path, "entries") %>% 
            janitor::clean_names()
        cv$contacts <- googlesheets4::read_sheet(path, "contact") %>% 
            janitor::clean_names()
        cv$skills <- googlesheets4::read_sheet(path, "skill") %>% 
            janitor::clean_names()
    }else{
        cv$entries <- openxlsx::read.xlsx(path, "entries") %>% 
            tibble::as_tibble() %>% 
            janitor::clean_names()
        cv$contacts <- googlesheets4::read_sheet(path, "contact") %>%
            tibble::as_tibble() %>% 
            janitor::clean_names()
        cv$skills <- googlesheets4::read_sheet(path, "skill") %>% 
            tibble::as_tibble() %>% 
            janitor::clean_names()
    }
    cv
}

print_contact_info <- function(cv){
    df <- cv$contacts %>%
        rowwise() %>% 
        mutate(label = case_when(
            loc %in% c("google scholar") ~ "chun-su",
            loc %in% c("website") ~ str_split(basename(contact), "\\.")[[1]][1],
                             TRUE ~ basename(contact))) %>%
        ungroup() %>% 
        mutate(label = ifelse(
            loc %in% c("github", "twitter"),
            str_replace(label, "^", "@"),
            label
        )) %>%
        mutate(contact = ifelse(loc == "email", str_replace(contact, "^", "mailto:"), contact)) %>%
        mutate(out = ifelse(
            loc %in% c("google scholar"),
            # glue::glue("<i class='ai ai-{icon}'></i> [{label}]({contact})"),
            glue::glue("<i class='fa fa-google'></i> [{label}]({contact})"),
            glue::glue("<i class='fa fa-{icon}'></i> [{label}]({contact})")
        ))
    
    glue::glue_data(
        df,
        "- {out}"
    ) %>% print()
    
    invisible(cv)
}

print_skills <- function(cv){
    cv$skills %>% 
        filter(in_resume, in_highlights) %>% 
        glue::glue_data(
            "-  <i class='fa fa-dot-circle-o'></i> {title}"
        ) %>% print()
}

print_section <- function(cv, section_id, glue_template = "default"){
    df <- cv$entries %>% 
        filter(section == section_id, in_resume) %>% 
        tidyr::unite(
            tidyr::starts_with('description'),
            col = "description_bullets",
            sep = "\n- ",
            na.rm = TRUE
        ) %>% 
        dplyr::mutate(
            description_bullets = ifelse(description_bullets != "", paste0("- ", description_bullets), ""),
            no_start = is.na(start),
            has_start = !no_start,
            no_end = is.na(end),
            has_end = !no_end,
            timeline = dplyr::case_when(
                no_start  & no_end  ~ "N/A",
                no_start  & has_end ~ as.character(end),
                has_start & no_end  ~ paste("Current", "-", start),
                TRUE                ~ paste(end, "-", start)
            )
        ) %>%
        dplyr::arrange(!is.na(end), desc(end)) %>%
        dplyr::mutate_all(~ ifelse(is.na(.), 'N/A', .))
    
    if(glue_template == "default"){
        glue_template <- "
### {title}

{institution}

{loc}

{timeline}


{description_bullets}

\n\n\n"
    }
    glue::glue_data(df, glue_template) %>% 
        print()
}