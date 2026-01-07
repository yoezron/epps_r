# NETWORK ANALYSIS SCRIPTS - COMPLETE GUIDE

## 📊 Overview

Anda sekarang memiliki **4 script Network Analysis** yang comprehensive:

| Script | Focus | Output Files | Waktu |
|--------|-------|--------------|-------|
| `08_Network_Analysis.R` | **Basic Network** | 4 tables, 3 plots | 5-10 min |
| `08B_Advanced_Network.R` | **Extended Metrics** | 10 tables, 9 plots | 10-15 min |
| `08C_Comparative_Network.R` | **Comparative & Predictability** | 10 tables, 10+ plots | 15-20 min |
| `08D_Interactive_Network.R` | **Interactive Visualizations** | 7 tables, 5 HTML interactive | 10-15 min |

**Total:** 31 tables, 25+ visualizations, 40-60 minutes

---

## 🎯 Script Details

### Script 08: Basic Network Analysis

**File:** `08_Network_Analysis.R`

**Fokus:** Foundation network analysis

**Output:**

**Tables:**
- `25_Network_Centrality.csv` - Strength, betweenness, closeness
- `26_Network_Clustering.csv` - Clustering coefficient per node
- `27_Network_EdgeWeights.csv` - All edge connections
- `28_Network_Communities.csv` - Community membership

**Plots:**
- `Network_GGM.png` - Basic network visualization
- `Network_Centrality.png` - Centrality measures barplot
- `Network_Communities.png` - Network with community colors

**Kapan Gunakan:**
- ✅ First-time network analysis
- ✅ Quick overview network structure
- ✅ Client presentations (simple, clear)

---

### Script 08B: Advanced Network Analysis

**File:** `08B_Advanced_Network.R`

**Fokus:** Extended network metrics dan analisis mendalam

**Output:**

**Tables:**
- `29_Network_Centrality_Extended.csv` - 6 centrality measures
- `30_Network_Bridge_Centrality.csv` - Bridge nodes between communities
- `31_Network_Global_Metrics.csv` - Density, transitivity, modularity
- `32_Network_Cliques.csv` - Maximal cliques (subgroups)
- `33_Network_Dyad_Census.csv` - Dyad relationships
- `34_Network_Triad_Census.csv` - Triad patterns
- `35_Network_Community_Correlations.csv` - Within vs between community
- `36_Network_Edge_Betweenness.csv` - Critical edges
- `37_Network_Shortest_Paths.csv` - Paths between key nodes
- `38_Network_Edge_Statistics.csv` - Positive vs negative edges

**Plots:**
- `Network_Spring_Layout.png` - Spring layout visualization
- `Network_Circle_Layout.png` - Circle layout
- `Network_Groups_Layout.png` - Groups layout
- `Network_Centrality_Extended.png` - All centrality measures
- `Network_Bridge_Centrality.png` - Bridge nodes
- `Network_Edge_Betweenness.png` - Top 20 critical edges
- `Network_Heatmap.png` - Correlation heatmap
- `Network_Positive_Only.png` - Positive correlations only
- `Network_Negative_Only.png` - Negative correlations (ipsativity)

**Kapan Gunakan:**
- ✅ Deep network analysis
- ✅ Academic papers
- ✅ Detailed psychometric reports
- ✅ Understanding network structure in depth

**Key Features:**
- 6 different centrality measures (not just 3)
- Bridge centrality (identifies connectors between communities)
- Clique analysis (finds tight subgroups)
- Dyad & Triad census (micro-level patterns)
- Separate visualization of positive vs negative edges

---

### Script 08C: Comparative Network & Predictability

**File:** `08C_Comparative_Network.R`

**Fokus:** Network comparison across groups & node predictability

**Output:**

**Tables:**
- `39_NCT_Gender_Comparison.csv` - Network comparison test results
- `40_Node_Predictability.csv` - R² for each node
- `41_Most_Stable_Edges.csv` - Top 20 most stable connections
- `42_Least_Stable_Edges.csv` - Top 20 least stable connections
- `43_Expected_Influence.csv` - 1-step & 2-step influence
- `44_Network_Flow_Metrics.csv` - Information flow measures
- `45_Network_Bottlenecks.csv` - Bottleneck nodes
- `46_Network_Resilience.csv` - Impact of node removal
- `47_Small_World_Properties.csv` - Small-worldness metrics
- `48_Centrality_Correlations.csv` - Correlations between centrality measures

**Plots:**
- `Network_[Gender].png` - Network per gender group
- `Network_Edu_[Level].png` - Network per education level
- `Network_Predictability.png` - Node predictability barplot
- `Network_With_Predictability.png` - Network with pie charts
- `Network_Expected_Influence.png` - Expected influence ranking
- `Network_Resilience.png` - Fragmentation by node removal
- `Network_Centrality_Correlations.png` - Centrality correlation heatmap
- `Network_Gender_Comparison.png` - NCT results (if applicable)

**Kapan Gunakan:**
- ✅ Compare networks across demographics
- ✅ Understand node predictability
- ✅ Test network differences statistically
- ✅ Identify critical nodes for intervention
- ✅ Network resilience analysis

**Key Features:**
- **Network Comparison Test (NCT):** Statistical test for network differences
- **Node Predictability:** How well each node can be predicted from others (R²)
- **Edge Stability:** Bootstrap analysis of edge reliability
- **Expected Influence:** Direct + indirect influence of each node
- **Resilience Analysis:** What happens if we remove each node?
- **Small-World Properties:** Is the network small-world?

**Important Notes:**
- NCT can take 5-15 minutes (100 permutations)
- Requires minimum 100 participants per group
- Predictability = variance explained by other nodes

---

### Script 08D: Interactive Network Visualization

**File:** `08D_Interactive_Network.R`

**Fokus:** Interactive HTML visualizations dan dynamic analysis

**Output:**

**Tables:**
- `49_Network_Growth_Sequence.csv` - Network growth by threshold
- `50_Temporal_Network_Metrics.csv` - Metrics across time windows
- `51_Network_3D_Coordinates.csv` - 3D positions for nodes
- `52_Dashboard_NetworkStats.csv` - Summary statistics
- `53_Dashboard_TopNodes.csv` - Top 10 central nodes
- `54_Dashboard_StrongestEdges.csv` - Top 10 edges
- `55_Dashboard_Communities.csv` - Community details

**Interactive Plots (HTML):**
- `Network_Interactive_visNetwork.html` - **Zoomable, clickable network**
- `Network_Force_Directed_D3.html` - **Physics-based simulation**
- `Network_Sankey_TopConnections.html` - **Flow diagram**
- `Network_Radial_Communities.html` - **Radial tree**
- `Network_3D_Interactive.html` - **3D rotatable network**

**Static Plots:**
- `Network_Growth_Curve.png` - Network growth visualization
- `Network_Temporal_Changes.png` - Changes over time
- `Network_[Node]_Q[1-4].png` - Networks by quartile (for top 3 nodes)

**Kapan Gunakan:**
- ✅ Client presentations (impressive visuals)
- ✅ Exploration & discovery
- ✅ Publications needing interactive figures
- ✅ Web-based reports
- ✅ Teaching/demonstrations

**Key Features:**
- **visNetwork:** Zoom, pan, click nodes, highlight connections
- **Force-Directed D3:** Physics simulation, dynamic layout
- **Sankey Diagram:** Shows flow of strongest connections
- **3D Plotly:** Rotate, zoom, explore in 3D space
- **Temporal Analysis:** Simulate network changes over time
- **Quartile Networks:** How network changes by trait levels

**How to Use Interactive Files:**
1. Open `.html` files in web browser (Chrome, Firefox, Edge)
2. Use mouse to zoom, pan, rotate
3. Hover over nodes for details
4. Click nodes to highlight connections
5. Use navigation buttons in visNetwork

---

## 🚀 Usage Guide

### Option 1: Run All Network Scripts

```r
# Setup
setwd("D:/1 NSD Project/EPPS/EPPS-Analysis")
load("output/data_processed.RData")

# Run all network analyses
source("08_Network_Analysis.R")        # 5-10 min
source("08B_Advanced_Network.R")       # 10-15 min
source("08C_Comparative_Network.R")    # 15-20 min
source("08D_Interactive_Network.R")    # 10-15 min

# Total: 40-60 minutes
```

### Option 2: Run Selected Scripts

**For Basic Analysis Only:**
```r
source("08_Network_Analysis.R")
```

**For Comprehensive Analysis:**
```r
source("08_Network_Analysis.R")
source("08B_Advanced_Network.R")
```

**For Client Presentation:**
```r
source("08_Network_Analysis.R")
source("08D_Interactive_Network.R")  # Interactive visuals
```

**For Academic Paper:**
```r
source("08B_Advanced_Network.R")     # Extended metrics
source("08C_Comparative_Network.R")  # Statistical tests
```

### Option 3: Integrate with Master Script

Edit `MASTER_RUN_ALL.R`:

```r
# Network Analysis
results$network <- run_script("08_Network_Analysis.R", 
                             "Network Analysis")

# Optional: Extended analyses
if(run_extended_network) {
  results$network_adv <- run_script("08B_Advanced_Network.R",
                                   "Advanced Network")
  results$network_comp <- run_script("08C_Comparative_Network.R",
                                    "Comparative Network")
  results$network_viz <- run_script("08D_Interactive_Network.R",
                                   "Interactive Network")
}
```

---

## 📊 Output Summary

### Total Output

**Tables:** 31 CSV files
- Basic network: 4 files
- Advanced metrics: 10 files
- Comparative analysis: 10 files
- Interactive/dashboard: 7 files

**Visualizations:** 25+ plots
- Static PNG: 20+ files
- Interactive HTML: 5 files

**File Size:** ~50-100 MB total

---

## 🎓 Interpretation Guide

### For Each Script

#### Script 08 - Basic Interpretation

**Centrality Measures:**
- **Strength:** Total connection weight - most interconnected node
- **Betweenness:** Bridges different parts of network
- **Closeness:** Central position, close to all other nodes

**Communities:**
- Groups of traits that cluster together
- High within-group, low between-group correlations

**Use in Report:**
> "Network analysis identified [N] communities of traits. 
> [Trait X] showed highest centrality, indicating central 
> importance in the trait structure."

#### Script 08B - Advanced Interpretation

**Bridge Centrality:**
- Nodes connecting different communities
- High bridge = important for network cohesion

**Cliques:**
- Tight subgroups of highly interconnected traits
- All members connected to all other members

**Edge Betweenness:**
- Critical connections between communities
- Removing these edges fragments network

**Use in Report:**
> "Extended network analysis revealed [Trait X] as a bridge 
> node connecting [Community A] and [Community B]. Clique 
> analysis identified [N] tight subgroups."

#### Script 08C - Comparative Interpretation

**Node Predictability:**
- R² = variance explained by other traits
- High predictability = redundant with other traits
- Low predictability = unique trait

**NCT Results:**
- p < 0.05 = significant network difference
- Global strength = overall connectivity difference
- Edge invariance = specific edge differences

**Expected Influence:**
- Direct + indirect impact on network
- Higher = more influential trait

**Use in Report:**
> "Network comparison test revealed [significant/no significant] 
> difference between [Group A] and [Group B] (p = X.XX). 
> Node predictability ranged from X% to Y%, with [Trait Z] 
> showing lowest predictability (most unique)."

#### Script 08D - Interactive Interpretation

**3D Visualization:**
- Spatial distance = dissimilarity
- Clusters = communities
- Useful for exploring structure

**Temporal Changes:**
- How network evolves across subsamples
- Stability of network structure

**Growth Curve:**
- How many connections at different thresholds
- Threshold choice validation

**Use in Report:**
> "Interactive visualizations allow exploration of trait 
> relationships. 3D analysis confirmed [N] distinct clusters. 
> Network growth analysis showed stable structure across 
> threshold range [X-Y]."

---

## ⚠️ Important Notes

### Ipsativity Effect

**Remember:** EPPS is forced-choice, causing ipsativity

**Impact on Network:**
- Negative correlations may be artifactual
- Sum of all traits = constant
- Some negative edges are mathematical necessity

**How Scripts Handle This:**
- Script 08B separates positive vs negative networks
- Regularization applied when needed
- Focus on magnitude, not sign of correlations

**Interpretation:**
- ✅ Focus on: relative centrality, community structure, patterns
- ❌ Avoid: exact correlation values, causal claims

### Computational Notes

**Memory Requirements:**
- Script 08: <1 GB RAM
- Script 08B: 1-2 GB RAM
- Script 08C: 2-4 GB RAM (NCT is intensive)
- Script 08D: 1-2 GB RAM

**Time Estimates:**
- With 6464 respondents
- NCT: 5-15 minutes (can disable if needed)
- Bootstrap in 08C: 5-10 minutes
- Interactive plots: 2-5 minutes each

**Speed Tips:**
```r
# In 08C, reduce NCT iterations
nct_result <- NCT(data1, data2, it = 50)  # Instead of 100

# Skip bootstrap stability
run_bootstrap <- FALSE  # In 08_Network_Analysis.R

# Reduce sample for interactive plots
sample_size <- 500  # In 08D
```

---

## 📝 For Reports

### Executive Summary Template

> "**Network Analysis - Aspek Kepribadian EPPS**
> 
> Kami melakukan comprehensive network analysis untuk memahami 
> struktur hubungan antar 15 aspek kepribadian EPPS. Analysis 
> menggunakan 4 complementary approaches:
> 
> 1. **Basic Network Analysis:** Mengidentifikasi [N] communities 
>    dan centrality measures untuk setiap aspek.
> 
> 2. **Extended Metrics:** Bridge centrality, clique analysis, dan 
>    detailed edge analysis mengungkap struktur mikro network.
> 
> 3. **Comparative Analysis:** Network comparison across demographics 
>    [showed/did not show] significant differences. Node predictability 
>    analysis identified traits yang paling/paling tidak redundant.
> 
> 4. **Interactive Visualizations:** Interactive HTML plots memungkinkan 
>    exploration mendalam dari trait relationships.
> 
> **Key Findings:**
> - Aspek [X, Y, Z] adalah most central traits
> - [N] distinct communities identified
> - Mean node predictability: [XX%]
> - [Significant/No significant] gender differences in network structure
> 
> **Implications:**
> Network structure konsisten dengan teori kepribadian [theory], 
> dengan [specific findings] supporting [specific hypothesis]."

### Figure Captions

**For Basic Network:**
> "Figure X. Network visualization of 15 EPPS traits. Node size 
> represents strength centrality. Edge color: green = positive 
> correlation, red = negative correlation (may reflect ipsativity). 
> Communities detected using Louvain algorithm (N = [X] communities)."

**For Predictability:**
> "Figure X. Node predictability (R²) showing variance in each trait 
> explained by all other traits. Higher values indicate more redundancy 
> with other traits. [Trait X] shows lowest predictability (R² = X.XX), 
> suggesting unique contribution."

**For Interactive:**
> "Figure X. Interactive network visualization. Readers can zoom, 
> pan, and click nodes to explore trait relationships. Available 
> at [URL/supplementary materials]."

---

## ✅ Checklist

Before running all scripts:
- [ ] Basic network analysis works (`08`)
- [ ] Data has no missing issues
- [ ] Enough RAM (4GB+ recommended)
- [ ] Time available (1 hour for all)

After running:
- [ ] Check all tables created
- [ ] Open interactive HTML files
- [ ] Review key findings
- [ ] Prepare figures for report

---

## 🆘 Troubleshooting

**Error: "not positive definite"**
- Already fixed in all scripts with regularization
- Should not occur

**NCT taking too long:**
```r
# Reduce iterations in 08C
nct_result <- NCT(..., it = 50)  # Default 100
```

**Interactive plots not opening:**
- Use modern browser (Chrome, Firefox, Edge)
- Check file exists in output/plots/
- Try different browser if one fails

**Out of memory:**
- Run scripts one at a time
- Reduce sample size in scripts
- Close other programs

---

## 📚 References

**Network Analysis Methods:**
- Epskamp, S., et al. (2018). Estimating psychological networks and their accuracy. *Behavioral Research Methods*.
- Borsboom, D., & Cramer, A. O. (2013). Network analysis: An integrative approach to the structure of psychopathology. *Annual Review of Clinical Psychology*.

**Software:**
- qgraph (Epskamp et al.)
- igraph (Csardi & Nepusz)
- bootnet (Epskamp et al.)
- visNetwork (Almende B.V.)
- networkD3 (Allaire et al.)

---

**Last Updated:** 7 Januari 2025  
**Status:** ✅ ALL SCRIPTS PRODUCTION READY  
**Total Scripts:** 4  
**Total Output:** 31 tables + 25+ visualizations
