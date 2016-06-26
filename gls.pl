#!/usr/bin/perl 
#print "1 wynosi $ARGV[0].\n";
$licz_arg=@ARGV; if ($licz_arg == 0 ) {&help; exit 0;}
use Getopt::Std;
getopts('ghl:f:mand:i'); # n-l structure
if ($opt_h) { &help; exit 0;}
open (LOG, "$ARGV[0]") or die "cannot open file";
my $new_geom_start='Standard orientation:';
if ($opt_i) {
    $new_geom_start='Input orientation:';
}
my @xyz; #table each entry = one strcture
my $strnum=-1; #structure number started from 0
my $all_atoms=-1; #number of atoms in structures
my $prevline="noNe";
my $isCoord=0;
#my @temp; #tmp table
my $atomid=0;
#if ($opt_a) {$struct = $linum[$strnum];}
foreach (<LOG>){
    if ($_ =~ '---------------------------------------------------------------------' && $prevline =~ $new_geom_start){ ##new coord
	$strnum = $strnum +1;
	$isCoord=1;
	$atomid=0
    }
    elsif ($isCoord == 1 && $_ =~ '---------------------------------------------------------------------' ) {
	#table header -> just ignore
	$isCoord=2;
    }
    elsif ($isCoord == 2 && $_ =~ '---------------------------------------------------------------------' ) {
	#end of coordinates
	$isCoord=0;
	if ($all_atoms == -1 ) {
	    $all_atoms = $atomid;
	}
	elsif($all_atoms != $atomid)  {
	    print "error!!!\n\n\n";
	}
    }
    elsif ($isCoord == 2) {
	#true coordinates    
        #elsif ($co[2] == 8) { $symb='O';}
        $xyz[$strnum][$atomid]=$_; # 
        #print "$xyz[$strnum][$atomid] \n";
        $atomid=$atomid +1;
    }
    $prevline=$_;
} 
$numStr = @xyz; #how many str in array are
if ($opt_a) {
    for ($i=0; $i < $numStr; $i++) {
	if ($opt_m) { print "$all_atoms\n gen by gls\n"; }
	for ($j=0; $j < $all_atoms; $j++) {
	    formPrint($xyz[$i][$j]);
	}
    }
} elsif ($opt_f) {
    if ($opt_m) { print "$all_atoms\n gen by gls\n"; }
    for ($i=0; $i < $all_atoms; $i++) {
	formPrint($xyz[$opt_f-1][$i]);
    }
} elsif ($opt_l) {
    if ($opt_m) { print "$all_atoms\n gen by gls\n"; }
    my $s=$numStr-$opt_l; #last stucture is 1; so $numStr-1 is exactly last element so all correct (O.K.)
    for ($i=0; $i < $all_atoms; $i++) {	
	formPrint($xyz[$s][$i]);
    }
} elsif ($opt_n){
    print "$numStr\n";
} elsif ($opt_d) {
    #print "wykryte atm: $opt_d\n";
    my @atoms_pairs= split(/\,/, $opt_d);
    foreach (@atoms_pairs) { 
	@this_pair=split(/-/, $_);
	#print "$this_pair[0] $this_pair[1]\n";
	$str_id=$numStr-1;
	if ($opt_l || $opt_f) { die "not supported";} 
	if ($this_pair[0] > $all_atoms || $this_pair[1] > $all_atoms) {
	    die "there are only $all_atoms atoms in the structure!\n";
	}
	&dist($xyz[$str_id][$this_pair[0]-1], $xyz[$str_id][$this_pair[1]-1]);
    }
}else {
    my $s=$numStr-1; #last stucture is 1; so $numStr-1 is exactly last element so all correct (O.K.)
    if ($opt_m) { print "$all_atoms\n gen by gls\n"; }
    for ($i=0; $i < $all_atoms; $i++) {	
	#print "$xyz[$s][$i]\n";
	formPrint($xyz[$s][$i]);
    }
}
#print "fgdf $a";
close LOG;
##############################
sub dist {
    # $_[0] $_[1]
    my @first_atm=split(/\s+/, $_[0]);
    my @second_atm=split(/\s+/, $_[1]);
    # foreach (@first_atm) {print "$_\n";}
    my $x = abs($first_atm[4] - $second_atm[4]);
    my $y = abs($first_atm[5] - $second_atm[5]);
    my $z = abs($first_atm[6] - $second_atm[6]);
    #print "wyniki: $x $first_atm[4]  $second_atm[4] \n";    print "wyniki: $z $first_atm[6]  $second_atm[6] \n";
    my $distance = sqrt( ($x**2) + ($y**2) + ($z**2) );
    printf "%i\t %i\t %.3f \n", $first_atm[1], $second_atm[1], $distance;
}
sub formPrint {
    my $str=shift;
    #print ": $str ::\n";
    @co=split(/\s+/,$str);
    if ($co[2] == 1) { $symb='H';}
    elsif ($co[2] == 3) { $symb='Li';}
    elsif ($co[2] == 4) { $symb='Be';}
    elsif ($co[2] == 5) { $symb='B';}
    elsif ($co[2] == 6) { $symb='C';}
    elsif ($co[2] == 7) { $symb='N';}
    elsif ($co[2] == 8) { $symb='O';}
    elsif ($co[2] == 9) { $symb='F';}
    elsif ($co[2] == 11) { $symb='Na';}
    elsif ($co[2] == 12) {$symb='Mg';}
    elsif ($co[2] == 13) { $symb='Al';}
    elsif ($co[2] == 14) {$symb='Si';}
    elsif ($co[2] == 15) { $symb='P';}
    elsif ($co[2] == 16) { $symb='S';}
    elsif ($co[2] == 17) { $symb='Cl';}
    elsif ($co[2] == 19) { $symb='K';}    
    elsif ($co[2] == 20) { $symb='Ca';}    
    elsif ($co[2] == 28) { $symb='Ni';}        
    elsif ($co[2] == 29) { $symb='Cu';}    
    elsif ($co[2] == 30) { $symb='Zn';}    
    elsif ($co[2] == 32) { $symb='Ge';}
    elsif ($co[2] == 35) { $symb='Br';}
    elsif ($co[2] == 37) { $symb='Rb';}
    elsif ($co[2] == 39) { $symb='Y';}
    elsif ($co[2] == 44) { $symb='Ru';}
    elsif ($co[2] == 45) { $symb='Rh';}
    elsif ($co[2] == 46) { $symb='Pd';}
    elsif ($co[2] == 47) { $symb='Ag';}
    elsif ($co[2] == 53) { $symb='I';}
    elsif ($co[2] == 55) { $symb='Cs';}
    elsif ($co[2] == 77) { $symb='Ir';}
    elsif ($co[2] == 78) { $symb='Pt';}
    elsif ($co[2] == 79) { $symb='Au';}
    else { $symb=$co[2];}
    ##
    if ($opt_g) {
	print "$symb  $co[2]  $co[4] $co[5] $co[6]\n"; 
    } else {
	print "$symb   $co[4]   $co[5]   $co[6]\n"; 
    }
}
sub help {
    print "gls.pl version 18.11.2012\n Usage gls.pl OPTION FILE \n options:\n";
    print " -l NUMBER ->  print structure number NUMBER starting from last (last=1 beware last geometry is repeted)\n";
    print " -f NUMBER ->  print structure number NUMBER starting from first (first=1)\n";
    print " -m        ->  print geometry in  molden xyz format\n";
    print " -a        ->  print all structures\n";
    print " -g        ->  print geometry in GAMESS format\n";
    print " -n        -> just print number of detected structures\n";
    print " -d NUM-NUM,NUM-NUM -> distance between given atoms\n";
    print " -i 	      -> sometimes coordinates starts with 'Input geometry' for this strange case use this option\n";
}
