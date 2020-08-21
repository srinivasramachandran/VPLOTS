#perl ../code/vplot_bed.pl ../lib/Reb1.list ../Dat/GSM1647331_Reb1_ChEC_seq_30s_1.bed.gz > Reb1_ChEC_single.vplot
#perl ../code/vplot_bed_list.pl ../lib/Reb1.list FILE_LIST > Reb1_ChEC_COMB.vplot
#sh ../scripts/vplot_figure.sh Reb1_ChEC_single.vplot
#sh ../scripts/vplot_figure.sh Reb1_ChEC_COMB.vplot
paste Reb1_ChEC_single.vplot Reb1_ChEC_COMB.vplot | awk '{print $1,$2,log(($3+0.001)/($7+0.001))}' > Differential.vplot
