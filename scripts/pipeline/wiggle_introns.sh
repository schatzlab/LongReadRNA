#!/bin/bash
set -o pipefail -o nounset -o errexit 
BEDTOOLS='/data/bedtools2/bin/bedtools'

WIGGLE=${1}
cat pre_novel_junctions | perl -ne 'BEGIN { $w='${WIGGLE}'; } chomp; $f=$_; ($c,$s,$e,$o,$nr,$reads,$pac,$nlr,$dist,$junctions)=split(/\t/,$f); $s1=$s-($w+1); $s2=$s+$w; $e1=$e-($w+1); $e2=$e+$w; print "".join("\t",($c,$s1,$s2,$o,$nr,$reads,$pac,$nlr,$dist,"$s-$e",0,$junctions))."\n"; print "".join("\t",($c,$e1,$e2,$o,$nr,$reads,$pac,$nlr,$dist,"$s-$e",1,$junctions))."\n";' | sort -k1,1 -k2,2n -k3,3n > pre_novel_junctions.split_ends.${WIGGLE}.bed

#find non-overlaps with list of all short read junctions looking for ends separately (to allow for distant containments/overlaps)
$BEDTOOLS intersect -sorted -a pre_novel_junctions.split_ends.${WIGGLE}.bed -b <(zcat ../../gtex_sra_junctions.split.bed.bgz) -v > novel_junctions_bt.w${WIGGLE}.raw

cat novel_junctions_bt.w${WIGGLE}.raw | perl -ne 'BEGIN { %h; } chomp; $f=$_; ($c,$c1,$c2,$o,$nr,$reads,$pac,$nlr,$dist,$coord,$t,$junctions)=split(/\t/,$f); $tnot=!$t; $k=$coord."-".$tnot; if($h{$k}) { print "".$h{$k}."\n"; delete($h{$k}); next; } $k=$coord."-".$t; $coord=~/^(\d+)-(\d+)$/; $c1=$1; $c2=$2; $h{$k}=join("\t",($c,$c1,$c2,$o,$nr,$reads,$pac,$nlr,$dist,$junctions));' | egrep -v -e '(_alt)|(_random)|(_decoy)' > novel_junctions_bt.w${WIGGLE}.both_ends

cat novel_junctions_bt.w${WIGGLE}.raw | perl -ne 'BEGIN { %h; } chomp; $f=$_; ($c,$c1,$c2,$o,$nr,$reads,$pac,$nlr,$dist,$coord,$t,$junctions)=split(/\t/,$f); $k=$coord; $coord=~/^(\d+)-(\d+)$/; $c1=$1; $c2=$2; if(!$h{$k}) { print "".join("\t",($c,$c1,$c2,$o,$nr,$reads,$pac,$nlr,$dist,$junctions))."\n"; } $h{$k}=1;' | egrep -v -e '(_alt)|(_random)|(_decoy)' > novel_junctions_bt.w${WIGGLE}.either_end
