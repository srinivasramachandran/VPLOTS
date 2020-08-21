if [ -e $1 ];then
	l=`cat $1 | wc -l | awk '{print int($1*0.001)}'`
	hi=`awk '{print $3}' $1 | sort -gr | head -n $l | tail -n 1`
	echo $1 $hi $l
	j=`echo $1 | sed 's/_/ /g'`
	cat > plt << eofx
set terminal pdfcairo font "Arial,14"
set termoption dash
set xra [-200:200]
set xtics -150,50,150
set ytics 0,25,200
unset key
set colorbox user origin graph 1.01, graph 0.1 size 0.035, graph 0.8
set style line 1 lw 4 lc rgb "#FD8D3C"
set style line 2 lt 2 lw 7 lc rgb "#858585"
set output "${1}.pdf"
set palette defined ( 0 "#f2f0f7", 0.04 "#bdd7e7", 0.12 "#6baed6", 0.25 "#3182bd", 0.4 "#08519c", 0.6 "#9e9ac8", 1 "#756bb1")
set size ratio 0.5
set ytics 0,50,200
set yra [0:200]
set cbr [0:$hi]
plot '${1}' u 1:2:3 w image
eofx
	gnuplot < plt
else
	echo "$1 not found"
fi
