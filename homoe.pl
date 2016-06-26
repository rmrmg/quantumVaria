#!/usr/bin/perl -w
$stdHomo=99;
foreach (@ARGV) {
    print "\n", $_, "  ";
    $str='grep "occ. eigenvalues -- " ' . $_ . ' | tail -n 1';
    $e=`$str`;
    @std=split(/\s+/, $e);
    if ($#std < 3) {
	print " ..";
	next;
    }
    $this_e=$std[-1];
    print "\t (", $this_e, ") \t" ;
    if ($stdHomo == 99) {
        $stdHomo=$this_e;
    } else {
	$ener=$this_e-$stdHomo;
	print $ener;
    }
}
print "\n";