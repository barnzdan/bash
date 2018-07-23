#!/usr/bin/perl 

$g=0;

while (<>) { 
  if (/TINFO:(.*?),9,.*,\"(\d\d?):(\d\d?):(\d\d?)\"/) {
    $x=($2*3600)+($3*60)+$4;
    $z=$_;
    if($x>$g){
      $g=$x;
      $t=$1;
      $tlength="$2:$3:$4";
    } 
  } 
} 

#print "Longest Title Id is : $t - $tlength\n";
#print "$z";
#print "$y";
print "$tlength \n"
