# fig_L05_dual_citizenship_europe_cat.R
# Maarten Vink — 2026-05-04
# Companion to fig_L05_dual_citizenship_europe.R: same map but coloured by the
# *type* of L05 provision (collapsed L05_cat) rather than a binary yes/no.
# Source is GLOBALCIT v3.1 (year 2024) with two manual overrides reflecting
# reforms in force on the snapshot date (4 May 2026):
#   DEU — StARModG, in force 2024-06-27 → cat 0 (No provision)
#   UKR — multiple-citizenship law, in force 2026-01-16 → cat 5
#         (Generally applicable provision but with exceptions, withdrawal)
#
# Category collapse:
#   0   →  "No provision"
#   1+2 →  "Generally applicable (lapse)"
#   3+6 →  "Only applies to naturalised citizens"
#   4+5 →  "Generally applicable (withdrawal)"

library(tidyverse)
library(sf)
library(rnaturalearth)
library(here)

reference_year <- 2026L

v31_path <- here("data", "data_v3.1_country-year.csv")

# Council of Europe member states (46 members, post-2022; Russia expelled)
coe_iso3 <- c(
  "ALB", "AND", "ARM", "AUT", "AZE", "BEL", "BIH", "BGR", "HRV", "CYP",
  "CZE", "DNK", "EST", "FIN", "FRA", "GEO", "DEU", "GRC", "HUN", "ISL",
  "IRL", "ITA", "LVA", "LIE", "LTU", "LUX", "MLT", "MDA", "MCO", "MNE",
  "NLD", "MKD", "NOR", "POL", "PRT", "ROU", "SMR", "SRB", "SVK", "SVN",
  "ESP", "SWE", "CHE", "TUR", "UKR", "GBR"
)

# Manual L05_cat overrides for reforms in force on the snapshot date
overrides <- tribble(
  ~iso3, ~l05_cat_new,
  "DEU",  0L,
  "UKR",  5L
)

# Collapse 1+2, 3+6, 4+5
collapse_cat <- function(x) {
  case_when(
    x == 0L           ~ "No provision",
    x %in% c(1L, 2L)  ~ "Generally applicable (lapse)",
    x %in% c(3L, 6L)  ~ "Only applies to naturalised citizens",
    x %in% c(4L, 5L)  ~ "Generally applicable (withdrawal)",
    TRUE              ~ NA_character_
  )
}

cat_levels <- c(
  "No provision",
  "Only applies to naturalised citizens",
  "Generally applicable (lapse)",
  "Generally applicable (withdrawal)"
)

# Read v3.1 status for 2024 and apply overrides
status <- read_csv(v31_path, show_col_types = FALSE) |>
  filter(iso3 %in% coe_iso3, year == 2024) |>
  select(iso3, country, l05_cat = L05_cat) |>
  mutate(l05_cat = as.integer(l05_cat)) |>
  left_join(overrides, by = "iso3") |>
  mutate(
    l05_cat = coalesce(l05_cat_new, l05_cat),
    l05_collapsed = factor(collapse_cat(l05_cat), levels = cat_levels)
  ) |>
  select(iso3, country, l05_cat, l05_collapsed)

write_csv(
  status,
  here("tables", paste0("L05_categories_council_of_europe_", reference_year, ".csv"))
)

# Pull a world basemap and join with status. Non-CoE countries (e.g. Belarus,
# Russia) keep their geometry but get NA in l05_collapsed and so render as
# na.value (grey85), giving geographic context without falsely colouring
# them as part of the CoE universe. coord_sf crops to the European frame.
basemap <- ne_countries(scale = "medium", returnclass = "sf") |>
  select(iso_a3 = iso_a3_eh, name, geometry)

map_df <- basemap |>
  left_join(status, by = c("iso_a3" = "iso3"))

# Okabe-Ito 4-colour palette (colourblind-safe), ordered roughly by severity
palette_l05_cat <- c(
  "No provision"                      = "#0072B2",
  "Only applies to naturalised citizens"                  = "#56B4E9",
  "Generally applicable (lapse)"      = "#E69F00",
  "Generally applicable (withdrawal)" = "#D55E00"
)

p <- ggplot(map_df) +
  geom_sf(aes(fill = l05_collapsed), colour = "white", linewidth = 0.2) +
  coord_sf(xlim = c(-25, 50), ylim = c(34, 71), expand = FALSE) +
  scale_fill_manual(
    values = palette_l05_cat,
    drop = FALSE,
    breaks = cat_levels,
    na.value = "grey85",
    name = "Type of loss provision"
  ) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE, title.position = "top")) +
  labs(
    title = paste0("Dual citizenship and loss of citizenship in Europe, ", reference_year),
    subtitle = "Type of provision under which voluntary acquisition of another citizenship can lead to loss of citizenship",
    caption = paste(
      "Source: GLOBALCIT v3.1 with updates for Germany and Ukraine*. Council of Europe states, 4 May 2026.",
      str_wrap(
        "*Since Jan. 2026, loss applies only when an adult voluntarily acquires citizenship of an aggressor/occupying state or of a state outside Ukraine's simplified-citizenship list (Canada, Germany, Poland, US, Czechia).",
        width = 110
      ),
      str_wrap(
        "#Spain: Loss applies only to citizens resident abroad and is avoidable by a declaration of retention within 3 years.",
        width = 110
      ),
      sep = "\n"
    )
  ) +
  theme_minimal(base_size = 11) +
  theme(
    panel.grid = element_blank(),
    axis.title = element_blank(),
    axis.text = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(face = "bold"),
    plot.subtitle = element_text(margin = margin(b = 8))
  )

ggsave(here("figures", paste0("fig_L05_dual_citizenship_europe_cat_", reference_year, ".pdf")),
       p, width = 24, height = 22, units = "cm")
ggsave(here("figures", paste0("fig_L05_dual_citizenship_europe_cat_", reference_year, ".png")),
       p, width = 24, height = 22, units = "cm", dpi = 300)
