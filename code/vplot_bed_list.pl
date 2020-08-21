#!/usr/bin/perl

# v0.1 Author: Srinivas Ramachandran

die "perl vplot_bed.pl <Peak_FILE> <BED_FILE_LIST> > <VPLOT>\n" if(!$ARGV[1]);


open(FILE,$ARGV[0]) || die "Peak file $!\n";
while(chomp($line=<FILE>)){
	@temp = split /[\ \s\n\t]+/, $line;
	$chr = $temp[1];
	$chr =~s/^chr// ;
	$peak = $temp[3];
	$nsites++;
	if($temp[4] eq "+" ){
		for($i=$peak-400;$i<=$peak+400;$i++){
			$pos{$chr}{$i} = $i-$peak;
			$str{$chr}{$i}="+";
		}
	}elsif($temp[4] eq "-"){
		for($i=$peak+400;$i>=$peak-400;$i--){
			$pos{$chr}{$i} = $peak-$i;
			$str{$chr}{$i} ="-";
		}
	}
}
close(FILE);

$id=0;
$total_count=0;

# Column	Value
# 0				Chromosome
#	1				Start
# 2 			End
# 3				Length

open(LIST,$ARGV[1]) || die "INPUT FILE LIST $!\n";
while(chomp($file=<LIST>)){
	print "$file\n";
	if($file=~/.gz$/){
  	open(FILE,"gunzip -c $file |") || die "$!\n";
	}else{
		open(FILE,$file) || die "$!\n";
	}
	while(chomp($line=<FILE>)){
		$id++;
		@temp = split /[\ \s\n\t]+/, $line;
		if($#temp < 2){
			print STDERR "Not regular BED line?\n$line\n";
		}else{
			$mp = int( ($temp[1] + 1 +$temp[2])/2 + 0.5 );
			$temp[0]=~s/^chr//;
			$temp[3]=$temp[2]-$temp[1];
			if( exists $pos{$temp[0]}{$mp}){
				$matrix{$pos{$temp[0]}{$mp}}{$temp[3]}++;
				$nuc_count++ if($temp[3]>=142 && $temp[3]<=152 && $pos{$temp[0]}{$mp} >=-15 && $pos{$temp[0]}{$mp} <=15);
				$total_count++;
				if($str{$temp[0]}{$mp} eq "-"){
					$peak = $mp + $pos{$temp[0]}{$mp};
				}else{
					$peak = $mp - $pos{$temp[0]}{$mp};
				}
				$count{$temp[0]}{$peak}++; 
				#print STDERR "$mp $pos{$temp[0]}{$mp} $peak\n";
			}
		}
		if($id%1000000==0){
			$x=sprintf("%E\n",$id);
			print STDERR  $x ;
		}
	}
	close(FILE);
}
close(LIST);

print STDERR "total count: $total_count\nnuc_count: $nuc_count";

foreach $i ( keys(%count)) {
	foreach $j (keys(%{$count{$i}}) ) {
		print STDERR "$i $j $count{$i}{$j}\n";
	}
}

for($i=-400;$i<=400;$i++){
	for($j=0;$j<=400;$j++){
		$val = 0;
		#$val = $matrix{$i}{$j}*130000000/($nsites*$total_count) if(exists $matrix{$i}{$j}); # normalize by total reads and total number of sites. Multiply by genome size.
		$val = $matrix{$i}{$j}*31*11/$nuc_count if(exists $matrix{$i}{$j}); # normalize by total reads 147±5, multiplied by number of horizontal cells. Also normalize by total number of sites.
		$raw_val = 0 ;
		$raw_val = $matrix{$i}{$j} if(exists $matrix{$i}{$j});
		print "$i $j $val $raw_val\n";
	}
}
