GLOBALCIT — Dual citizenship and loss of citizenship in Europe (mode L05)
=========================================================================

Replication package for a single map figure showing the type of provision
under which voluntary acquisition of another citizenship can lead to
involuntary loss of citizenship (GLOBALCIT mode L05) across the 46 Council
of Europe member states. Status snapshot: 4 May 2026.

Author: Maarten Vink (European University Institute)
Contact: maarten.vink@eui.eu


Folder structure
----------------
code/      R script that builds the figure
data/      input data — local copy of the GLOBALCIT v3.1 country-year file
figures/   output figure (.pdf and .png)
tables/    output table (.csv) with the country-level category coding


Reproducing the figure
----------------------
1. Open this folder in R (>= 4.2). If you use RStudio, open
   L05_replication.Rproj so that the working directory is set automatically.

2. Install the required packages (one-off):

       install.packages(c("tidyverse", "sf", "rnaturalearth",
                          "rnaturalearthdata", "here"))

3. Source the script:

       source("code/fig_L05_dual_citizenship_europe_cat.R")

   The script reads data/data_v3.1_country-year.csv, writes the figure to
   figures/, and writes the country-level table to tables/.


Source data
-----------
Vink, Maarten, Luuk van der Baaren, Rainer Bauböck, Jelena Džankić,
Iseult Honohan and Bronwen Manby (2025). GLOBALCIT Citizenship Law Dataset,
v3.1, Country-Year-Mode Data (Loss). Global Citizenship Observatory,
https://hdl.handle.net/1814/73190.

The script applies two manual overrides (defined as a small tibble at the top
of the script) reflecting reforms in force on the snapshot date:

  - Germany: Staatsangehoerigkeitsrechts-Modernisierungsgesetz (StARModG),
    in force 27 June 2024 — L05 moves from category 1
    ("Generally applicable provision (lapse)") to category 0 ("No provision").
  - Ukraine: multiple-citizenship law, in force 16 January 2026 — L05 moves
    from category 4 ("Generally applicable provision (withdrawal)") to
    category 5 ("Generally applicable provision but with exceptions
    (withdrawal)").

To refresh the snapshot for a later date, edit the `overrides` tibble at
the top of the script.


Category collapse
-----------------
The seven GLOBALCIT L05 categories are collapsed into four:

  0          ->  "No provision"
  1 + 2      ->  "Generally applicable (lapse)"
  3 + 6      ->  "Only applies to naturalised citizens"
  4 + 5      ->  "Generally applicable (withdrawal)"


Citation
--------
If you use or adapt this figure, please cite GLOBALCIT v3.1 as the underlying
data source and this replication package for the visualisation.
