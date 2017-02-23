---
title: "Possible Data Structures"
output:
  html_document:
    keep_md: yes
    toc: yes
    toc_depth: 5
---


### Current Structure

* Comes from our homegrown DHS warehouse, that combines PREMISS data with a little bit of REDCap.
* One row per referral
* Pros for analysis
    * Doesn't need more manipulation
* Cons for analysis
    * Can have multiple referrals with the same date.
    * It's sometimes confusing how removals and referrals should be paired


| client id| referral id| referral date| removal begin date| removal end date|
| -------- | ---------- | ------------ | ----------------- | --------------- | 
|         1|           1|       2014-01|      -            |       -         |
|         1|           1|       2014-01|            2014-02|          2014-04|
|         1|           2|       2015-01|            2015-02|          2015-06|
|         1|           3|       2016-01|         -         |       -         |
|          |            |              |                   |                 |
|         2|           4|       2014-01|         -         |       -         |
|         2|           5|       2014-07|            2014-08|          2014-10|
|         2|           6|       2015-01|            2015-03|       -         |
|          |            |              |                   |                 |
|         3|           7|       2014-01|         -         |       -         |
|         3|           8|       2015-01|         -         |       -         |
|          |            |              |                   |                 |
|         4|           9|       2015-01|         -         |       -         |
|          |            |              |                   |                 |
|         5|          10|       2014-08|            2014-11|          2014-12|

### Proposed structure

(*Transformed for just client 1 above*)

| client id | span index | start date | start event   | stop date | stop event    | state | iss |
|-----------|------------|------------|---------------|-----------|---------------|-------|-----|
| 1         | 1          | 2014-01    | referral      | 2014-02   | removal       | in    | n   |
| 1         | 2          | 2014-02    | removal       | 2014-04   | reunification | out   | y   |
| 1         | 3          | 2014-04    | reunification | 2015-01   | referral      | in    | n   |
| 1         | 4          | 2015-01    | referral      | 2015-02   | removal       | in    | y   |
| 1         | 5          | 2015-02    | removal       | 2015-06   | reunification | out   | y   |
| 1         | 6          | 2015-06    | reunification | 2016-01   | referral      | in    | n   |
| 1         | 7          | 2016-01    | referral      | +         | censored      | in    | y   |

* One row per "span".
* Fields: `start_date`, `start_event`, `stop_date`, `stop_event`, and `state`
    * start events include 'referral' or 'temp removal',
    * stop events include 'censored', 'reunification', 'temp removal', 'subsequent referral', 'permanent removal', 'age out'.
    * states include 'in-home' or 'out-of-home'.  Maybe some subcategories of out-of-home too.
* Pros for Analysis
    * Clarifies complexity.  
        * The four rows for client 1 should probably be enumerated/interpreted as 7 distinct spans (and that's even after collapsing the first two rows/referrals).
        * Explict record for "wrap around" span (eg, span 3 below, from 2014-04 to 2015-01)
    * Easily leads to calculated variables like 
        * span-level: 
            * `duration`
            * `duration_censored`
            * `duration_exposed_cumulative` (ie, running tally of removed duration)
            * `removal_tally` (ie, running tally of how many times client's been removed at that point)
        * client-level aggregations: 
            * `duration_exposed`
            * `duration_removed`
    * Does this fit with the conventional survival or multi-event analysis functions?
    * Could this structure be useful to other states or CPS agencies?  Could reduce the community's overall development costs, and help our analyses be more comparable.
* Cons for analysis
    * It's more work to develop (but maybe not, if the corner-cases are too hard with our existing approach)
    
### References

1. Therneau, Crowson, & Atkinson (2016).  `survival` package vignette: "Multi-state models and competing risks" https://cran.r-project.org/web/packages/survival/vignettes/compete.pdf
1. "Multistate Models" section of the "Survival Analysis" CRAN Task View: https://cran.r-project.org/web/views/Survival.html
1. Putter, Fiocco, & Geskus (2007). "Tutorial in biostatistics: Competing risks and multi-state models" *Statistics in Medicine*.
`S:/BBMC/literature/dhs/survival/putter-fiocco-geskus-2007-competing-risks-and-multistate-models.pdf`
1. Yung, & Liu (2007). "A joint frailty model for survival and gap times between recurrent events." *Biometrics*. https://www.ncbi.nlm.nih.gov/pubmed/17688491
1. Zhao, Zhou (2012). "Modeling gap times between recurrent events by marginal rate function." *Computation Statistics & Data Analysis*. http://www.sciencedirect.com/science/article/pii/S0167947311002829
