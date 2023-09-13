#!/usr/bin/perl
%opcode=(
	 DB   => -1,
	 DW   => -1,
	 DS   => -1,
	 LII  => 0x00,
	 LIJ  => 0x01,
	 LIA  => 0x02,
	 LIB  => 0x03,
	 IX   => 0x04,
	 DX   => 0x05,
	 IY   => 0x06,
	 DY   => 0x07,
	 MVW  => 0x08,
	 EXW  => 0x09,
	 MVB  => 0x0a,
	 EXB  => 0x0b,
	 ADN  => 0x0c,
	 SBN  => 0x0d,
	 ADW  => 0x0e,
	 SBW  => 0x0f,

	 LIDP => 0x10,
	 LIDL => 0x11,
	 LIP  => 0x12,
	 LIQ  => 0x13,
	 ADB  => 0x14,
	 SBB  => 0x15,
	 MVWD => 0x18,
	 EXWD => 0x19,
	 MVBD => 0x1a,
	 EXBD => 0x1b,
	 SRW  => 0x1c,
	 SLW  => 0x1d,
	 FILM => 0x1e,
	 FILD => 0x1f,

	 LDP  => 0x20,
	 LDQ  => 0x21,
	 LDR  => 0x22,
	 CLRA => 0x23,
	 IXL  => 0x24,
	 DXL  => 0x25,
	 IYS  => 0x26,
	 DYS  => 0x27,
	 JRNZP=> 0x28,
	 JRNZM=> 0x29,
	 JRNCP=> 0x2a,
	 JRNCM=> 0x2b,
	 JRP  => 0x2c,
	 JRM  => 0x2d,
	 LOOP => 0x2f,

	 STP  => 0x30,
	 STQ  => 0x31,
	 STR  => 0x32,
	 PUSH => 0x34,
	 RST  => 0x35,
	 DATA => 0x35,
	 RTN  => 0x37,
	 JRZP => 0x38,
	 JRZM => 0x39,
	 JRCP => 0x3a,
	 JRCM => 0x3b,

	 INCI => 0x40,
	 DECI => 0x41,
	 INCA => 0x42,
	 DECA => 0x43,
	 ADM  => 0x44,
	 SBM  => 0x45,
	 ANMA => 0x46,
	 ORMA => 0x47,
	 INCK => 0x48,
	 DECK => 0x49,
	 INCM => 0x4a,
	 DECM => 0x4b,
	 INA  => 0x4c,
	 NOPW => 0x4d,
	 WAIT => 0x4e,
	 CUP  => 0x4f,

	 INCP => 0x50,
	 DECP => 0x51,
	 STD  => 0x52,
	 MVDM => 0x53,
	 READM=> 0x54,
	 MVMD => 0x55,
	 READ => 0x56,
	 LDD  => 0x57,
	 SWP  => 0x58,
	 LDM  => 0x59,
	 SL   => 0x5a,
	 POP  => 0x5b,
	 OUTA => 0x5d,
	 OUTF => 0x5f,

	 ANIM => 0x60,
	 ORIM => 0x61,
	 TSIM => 0x62,
	 CPIM => 0x63,
	 ANIA => 0x64,
	 ORIA => 0x65,
	 TSIA => 0x66,
	 CPIA => 0x67,
	 CASE2=> 0x69,
	 JST  => 0x69,
	 TEST => 0x6b,
	 CDN  => 0x6f,

	 ADIM => 0x70,
	 SBIM => 0x71,
	 ADIA => 0x74,
	 SBIA => 0x75,
	 CALL => 0x78,
	 JP   => 0x79,
	 CASE1=> 0x7a,
	 SETT => 0x7a,
	 JPNZ => 0x7c,
	 JPNC => 0x7d,
	 JPZ  => 0x7e,
	 JPC  => 0x7f,

	 INCJ => 0xc0,
	 DECJ => 0xc1,
	 INCB => 0xc2,
	 DECB => 0xc3,
	 ADCM => 0xc4,
	 SBCM => 0xc5,
	 TSMA => 0xc6,
	 CPMA => 0xc7,
	 INCL => 0xc8,
	 DECL => 0xc9,
	 INCN => 0xca,
	 DECN => 0xcb,
	 INB  => 0xcc,
	 NOPT => 0xce,

	 SC   => 0xd0,
	 RC   => 0xd1,
	 SR   => 0xd2,
	 ANID => 0xd4,
	 ORID => 0xd5,
	 TSID => 0xd6,
	 LEAVE=> 0xd8,
	 EXAB => 0xda,
	 EXAM => 0xdb,
	 OUTB => 0xdd,
	 OUTC => 0xdf,

	 LP   => 0x80,
	 CAL  => 0xe0
	 );

%operand1=(			# mnemonic => # of bytes
	   LII  => 2,  LIJ  => 2,  LIA  => 2,
	   LIB  => 2,  LIDL => 2,  LIP	=> 2,
	   LIQ  => 2,  JRNZP=> 2,  JRNZM=> 2,
	   JRNCP=> 2,  JRNCM=> 2,  JRP  => 2,
	   JRM  => 2,  LOOP => 2,  JRZP => 2,
	   JRZM => 2,  JRCP => 2,  JRCM => 2,
	   WAIT => 2,  ANIM => 2,  ORIM => 2,
	   TSIM => 2,  CPIM => 2,  ANIA => 2,
	   ORIA => 2,  TSIA => 2,  CPIA => 2,
	   TEST => 2,  ADIM => 2,  SBIM => 2,
	   ADIA => 2,  SBIA => 2,  LP   => 1,
	   ANID => 2,  ORID => 2,  TSID => 2,
	   LIDP => 3,  CALL => 3,  JP   => 3,
	   JPNZ => 3,  JPNC => 3,  JPZ  => 3,
	   JPC  => 3,  CAL  => 2
	   );
%operandn=(
	   DB   => 0,  DW   => 0,  DS => 0
	   );
	   
#
#   START
#
print "\nYagshi's SC61860 assembler YASM61860 version 1.02\n";
sleep(1);

#for($i=0; $i<=$#ARGV; $i++){

while( $_=shift @ARGV ){
    if ($_ eq "-w"){
	$wavfile=shift @ARGV;
	next;
    }
    if ($_ eq "-d"){
	$dumpfile=shift @ARGV;
	next;
    }
    if ($_ eq "-r"){
	$rawfile=shift @ARGV;
	next;
    }
    if ($_=~/^.*\.s/i or $_=~/^.*\.asm/i){
	$sfile=$_;
	next;
    }
    if ($_ eq "-old" ){
	$oldwav=1;
	next;
    }
    die "usage: yasm.pl [-w wavfile.wav] [-d dumplist.txt] [-r rawfile.bin] [sourcefile.s]\n";
}
if( defined $wavfile ){
    open(WAV,"> $wavfile")
	or die "ERROR: cannot create wav file \"$wavfile\".\n";
    binmode WAV;
}
if( defined $rawfile ){
    open(RAW,"> $rawfile")
	or die "ERROR: cannot create raw binary file \"$rawfile\".\n";
    binmode RAW;
}
if( defined $dumpfile ){
    open(DUMP,"> $dumpfile")
	or die "ERROR: cannot create dump list file \"$dumpfile\".\n";
    $dump=DUMP;
}else{
    $dump=STDOUT;
}
if( defined $sfile ){
    open(SOURCE,"<$sfile")
	or die "ERROR: cannot open source file \"$sfile\".\n";
    $source=SOURCE;
}else{
    $source=STDIN;
}


print "pass 1\n";
$pcc=0;
$l=1;
PASS1LP:while(<$source>){
    chop;
    s/\t/ /g;			# replace TAB with SPC
    s/ *[^\\][#;].*$//;		# remove comment
    s/^[#;].*$//;		# remove comment
    s/  / /g;			# make space single
    s/^ *//;			# remove head space

    undef $thislabel;
    if( /^[^ ]+:/ || /^[^ ]+ EQU /i){
	$thislabel=$_;
	$thislabel=~s/ .*//;
	$thislabel=~s/:.*//;
	die "ERROR: multiple definitioin of $thislabel.\n"
	    if !($label{$thislabel} eq "");
	$label{$thislabel}=$pcc;
	if(/^[^ ]+ EQU /i){
	    $label{$thislabel}=evaluate($');
	    $_="";
	}

	printf "%10s  \$%04x\n",$thislabel,$label{$thislabel};
	s/^[^ ]+://;
	s/^ *//;
    }	
    next if /^$/;
    $opr[$l] = $_;
    $opr[$l] =~ s/^[^ ]+ //;
    s/ .*$//;
    if( /ORG/i ){
	die "ERROR: ORG cannot be labeled.($thislabel)\n"
	    if !($thislabel eq "");
	$pcc=evaluate($opr[$l]);
	die "ERROR: Illegal ORG address($pcc).\n"
	    if $pcc<0 || $pcc>0xffff;
	$opr[$l]="";
	$inst[$l]="";
	next PASS1LP;
    }

    $_=uc($_);
    $inst[$l]=$_;
    $addr[$l]=$pcc;
    die "ERROR: undefined instruction $_.\n" unless defined $opcode{$_};
    if(defined $operand1{$_}){
	$pcc += $operand1{$_};
    }
	elsif(defined $operandn{$_}){
	    if( /DB/i or /DW/i ){
		my $tmp=",".$opr[$l];
		until( $tmp eq "" ){
		    $tmp=~s/^,//;
		    die "ERROR: Illegal DB/DW syntax.\n"
			if( $& ne "," or $tmp eq "");
		    evaluate_expression($tmp);
		    $pcc += 1 if /DB/i;
		    $pcc += 2 if /DW/i;
		}
	    }
	    if( /DS/i ){
		my $tmp=$opr[$l];
		$pcc+=evaluate_expression($tmp);
		if($tmp ne ""){
		    $tmp=~s/^,//;
		    die "ERROR: Illegal DS syntax in $l.\n"
			if $& ne ",";
		    evaluate($tmp);
		}
	    }
	}
	else {
	    die "ERROR: $_ requires no operand in $l.\n"
		if( uc($opr[$l]) ne $_);
	    $opr[$l]="";
	    $pcc ++;
	}
    } continue {
	$l++;
    }
$lines=$l;
print "pass 2\n";


for($l=1,$p=0; $l<$lines; $binlen[$l++]=$p-$p0 ){
    $p0=$p;			# binlen calc you
    next if !$inst[$l];
    $bin[$p++]= $opcode{$inst[$l]} unless $opcode{$inst[$l]}==-1;
    next if $opr[$l] eq "";
    $_ = $inst[$l];
    if( /^JP/ || /CALL/ || /LIDP/ ){
	$ea=evaluate($opr[$l]);
	die "ERROR: Illegal address($ea) in line $l.\n"
	    if $ea<0 || $ea>0xffff;
	$bin[$p++]=($ea>>8);
	$bin[$p++]=($ea&0xff);
    } elsif ( /^JR/ || /LOOP/ ){
	$ea=evaluate($opr[$l]);
	$ea=$ea-$addr[$l]-1 if /^JR.*P/;
	$ea=$addr[$l]+1-$ea if /^JR.*M/ || /^LOOP$/ ;
	die "ERROR: Illegal relative address($ea) in line $l.\n"
	    if $ea<0 or $ea>0xff;
	$bin[$p++]=$ea;
    } elsif ( /^CAL$/ ){
	$ea=evaluate($opr[$l]);
	die "ERROR: CAL address out of range in line $l.\n"
	    if $ea<0 or $ea>0x1fff; 
	$bin[$p-1]=($ea>>8) + 0xe0;
	$bin[$p++]=$ea & 0xff;
    } elsif ( /^LP$/ ){
	$ea=evaluate($opr[$l]);
	die "ERROR: Illegal operand of LP in line $l.\n"
	    if $ea<0 || $ea>63;
	$bin[$p-1]=0x80+$ea;
    } elsif( /^DB$/ or /^DW$/ ){
	my $tmp=$opr[$l];
	$tmp = ",".$tmp;
	until( $tmp eq "" ){
	    $tmp=~s/^,//;
	    $data = evaluate_expression($tmp);
	    die "ERROR: value out or range in line $l.\n"
		if( $data<0 or $data > 0xffff or ($data > 0xff and /DB/) );
	    $bin[$p++] = ($data>>8) & 0xff if /DW/;
	    $bin[$p++] = $data & 0xff;
	}
    } elsif( /^DS$/ ){
	my $tmp=$opr[$l];
	$dsl =evaluate_expression($tmp);
	$dsd =0;
	if($tmp ne ""){
	    $tmp=~s/^,//;
	    $dsd=evaluate($tmp);
	    die "ERROR: value out of range in line $l.\n"
		if $dsd<0 or $dsd>0xff;
	}
	for($i=0; $i<$dsl; $i++){
	    $bin[$p++]=$dsd;
	}
    } else {
	$ea=evaluate($opr[$l]);
	die "ERROR: Illegal operand($ea) in line $l.\n"
	    if ($ea<0 or $ea>0xff);
	$bin[$p++]=$ea;
    }
}

print "complete.";
dumpout();
print "\n";
wavout() if defined $wavfile;

sub evaluate{
    my $expression=$_[0];
    my $expval = evaluate_expression($expression);
    die "ERROR: wrong expression.($_[0]) in $l\n"
	unless $expression eq "";
    return $expval;
}

sub evaluate_expression{
    evaluate_or_expression($_[0]);
}

sub evaluate_or_expression{
    my $val=evaluate_xor_expression($_[0]);
    while($_[0]=~s/^ *\| *//){
	$val=$val | evaluate_xor_expression($_[0]);
    }
    return $val;
}
sub evaluate_xor_expression{
    my $val=evaluate_and_expression($_[0]);
    while($_[0]=~s/^ *\^ *//){
	$val=$val ^ evaluate_and_expression($_[0]);
    }
    return $val;
}
sub evaluate_and_expression{
    my $val=evaluate_shift_expression($_[0]);
    while($_[0]=~s/^ *\& *//){
	$val=$val & evaluate_shift_expression($_[0]);
    }
    return $val;
}
sub evaluate_shift_expression{
    my $val=evaluate_additive_expression($_[0]);
    while($_[0]=~/^ *>>/ || $_[0]=~/^ *<</){
	$_[0]=~s/^ *//;
	$_[0]=~s/[>><<][>><<]//;
	$op=$&;
	$_[0]=~s/^ *//;
	$val=$val >> evaluate_additive_expression($_[0])
	    if $op=~/>>/;
	$val=$val << evaluate_additive_expression($_[0])
	    if $op=~/<</;
    }
    return $val;
}


sub evaluate_additive_expression{
    my $val=0;

    $_[0]=~s/^ *//;
    if( $_[0]=~/^\-/ ){
	$_[0]=~s/^\-//;
	$val=-evaluate_term($_[0]);
    }
    else{
	$_[0]=~s/^\+//;
	$val= evaluate_term($_[0]);
    }
    $_[0]=~s/^ *//;
    while($_[0]=~/^[\+\-]/){
	$_[0]=~s/^[\+\-]//;
	my $op=$&;
	$val += evaluate_term($_[0]) if $op=~/\+/;
	$val -= evaluate_term($_[0]) if $op=~/\-/;
    }
    return $val;
}

sub evaluate_term{
    my $fact=evaluate_factor($_[0]);
    $_[0]=~s/^ *//;
    while($_[0]=~/^[\/\*]/){
	$_[0]=~s/^ *//;
	$_[0]=~s/^[\/\*]//;
	my $op=$&;
	$_[0]=~s/^ *//;
	$fact *= evaluate_factor($_[0]) if $op=~/\*/;
	$fact /= evaluate_factor($_[0]) if $op=~/\//;
    }
    return $fact;
}

sub evaluate_factor{
    $_[0]=~s/^ *//;
    return $& if $_[0]=~s/^[0-9]+//i; #  decimal constant
    if( $_[0]=~/^\$[0-9A-F]+/i ){ # hex constant
	$_[0]=~s/^\$/0x/;
	$_[0]=~s/^0x[0-9A-F]+//i;
	return oct($&);
    }
    if( $_[0]=~/^\([^\)]+\)/ ){
	$_[0]=~s/^\(//;
	my $retval = evaluate_expression($_[0]);
	$_[0]=~s/\)//;
	return $retval;
    }
    if( $_[0]=~s/^\'// ){	# string or char constant
	my $retval = 0;
	while($_[0]){
	    return $retval if $_[0]=~s/^\'//;
	    $_[0]=~s/^\\//;
	    $_[0]=~s/^.//;
	    $retval=$retval*256+ord($&);
	}
	die "ERROR: Illegal string constant.\n";
    }
    else{
	$_[0]=~s/^[0-9A-Z\@\_\%]+//i;
	die "ERROR: undefined label($&)\n"
	    unless defined $label{$&};
	return $label{$&};
    }
}
    
sub dumpout{
    $pcc=-1;
    $sum=0;
    $ad=$addr[1];
    for($l=1,$p=0; $l<$lines; $l++ ){
	for( ; $ad < $addr[$l]; $ad++ ){
	    printf RAW chr(0) if defined $rawfile;
	}
	for( ; $ad<$addr[$l]+$binlen[$l]; $ad++ ){
	    if($pcc!=$ad or $ad%8==0){
		$sum=0;
		print $dump "\n\n" and $pcc=$ad unless $pcc==$ad;
		printf $dump "%04x : ",$ad>>3<<3;
		for($i=0;$i<$ad%8; $i++){
		    print $dump "   ";
		}
	    }
	    $sum+=$bin[$p];
	    printf RAW chr($bin[$p]) if defined $rawfile;
	    printf $dump "%02x ",$bin[$p++];
	    printf $dump ": %02x\n",$sum&0xff and $sum=0 if $pcc%8==7;
	    $pcc++;
	}
    }
}

sub wavout{	
    $topaddr=0xffff;
    $endaddr=0x0000;
    for($l=1;$l<$lines;$l++){
	$topl=$l and $topaddr=$addr[$l] if $topaddr>=$addr[$l] and defined $addr[$l];
	$endl=$l and $endaddr=$addr[$l] if $endaddr<=$addr[$l] and defined $addr[$l];
    }
    $endaddr+=$binlen[$endl]-1;
    $wl = ($endaddr-$topaddr+1+22+int(($endaddr-$topaddr+1)/120))
	*16*16+0x400*16;
        # header(ID,filename,addr,etc)+footer($ff,$ff,chksum)
        # lead
    $wl = ($endaddr-$topaddr+1+19+int(($endaddr-$topaddr+1)/8))
	*19*16+0x400*16 if $oldwav;
        # header(ID,filename,addr,etc)+footer($f0)
        # lead
    $w1="\xff\x00\xff\x00\xff\x00\xff\x00\xff\x00\xff\x00\xff\x00\xff\x00";
    $w0="\xff\xff\x00\x00\xff\xff\x00\x00\xff\xff\x00\x00\xff\xff\x00\x00";
    $sum=0;
    $sc=0;

    print WAV "RIFF";
    $wl = $wl +44-4;		# all(header:44+$wl) - 4
    printf WAV "%c%c%c%c"
	,$wl&0xff,($wl>>8)&0xff,($wl>>16)&0xff,($wl>>24)&0xff;
    $wl = $wl -44+4;
    print WAV "WAVEfmt ";
    print WAV "\x10\x00\x00\x00";
    print WAV "\x01\x00";		# PCM
    print WAV "\x01\x00";		# mono
    print WAV "\x40\x1f\x00\x00";	# sampling freq. = 8000Hz
    print WAV "\x40\x1f\x00\x00";	# byte / sec.
    print WAV "\x01\x00";		# byte / sample x channel
    print WAV "\x08\x00";		# bit / sample
    print WAV "data";
    printf WAV "%c%c%c%c"
	,$wl&0xff,($wl>>8)&0xff,($wl>>16)&0xff,($wl>>24)&0xff;


    for( $i=0; $i<0x400; $i++ ){
	print WAV $w1;
    }

    write1byte(0x67) unless $oldwav; # newer PC
    write1byte(0x26)   if   $oldwav; # 1245/125x
    $sum=0;
    unless($oldwav){
	write1(ord('I'));
	write1(ord('H'));
	write1(ord('S'));
	write1(ord('G'));
	write1(ord('A'));
	write1(ord('Y'));
	write1(0xf5);
	write1(0xf5);
	writesum();
    } else {
	write1(0);
	write1(0);
	write1(0);
	write1(0);
	write1(0);
	write1(0);
	write1(0);
	write1(0x5f);
	resetsum();
    }
    write1(0);
    write1(0);
    write1(0);
    write1(0);
    unless ($oldwav){
	write1($topaddr>>8 & 0xff);
	write1($topaddr & 0xff);
	write1(($endaddr-$topaddr)>>8&0xff);
	write1(($endaddr-$topaddr)&0xff);
	writesum();
    } else {			# PC-1245/125x
	write1($topaddr>>12 | ($topaddr>>4 &0xf0));
	write1(($topaddr<<4&0xf0) | ($topaddr>>4&0x0f));
	write1(($endaddr-$topaddr)>>12 | (($endaddr-$topaddr)>>4 &0xf0));
	write1((($endaddr-$topaddr)<<4&0xf0) | (($endaddr-$topaddr)>>4&0x0f));
	resetsum();
    }

    $ad=$topaddr;
    WAVLOOP0: while($ad<=$endaddr){
	$l=1;
	$p=0;
	while($ad!=$addr[$l]){
	    $p+=$binlen[$l];
	    $l++;
	    if($l==$lines){
		write1(0);
		$ad++;
		next WAVLOOP0;
	    }
	}
	while($ad==$addr[$l]){
	    for($i=0; $i<$binlen[$l];$i++){
		write1($bin[$p]>>4&0x0f | $bin[$p]<<4&0xf0) unless $oldwav;
		write1($bin[$p]) if $oldwav;
		$p++;
		$ad++;
	    }
	    $l++;
	}
    }
    unless( $oldwav ){
	$sc=0;
	write1(0xff);
	$tmpsum=$sum;
	write1(0xff);
	$sum=$tmpsum;
	writesum();
    } else {			# PC-1245/125x
	write1byte(0xf0);
    }
}


sub write1{
    write1byte($_[0]);
    unless($oldwav){
	$sum+=($_[0]&0xf);
	$sum=($sum+1)&0xff if $sum>0xff;
	$sum=($sum+($_[0]>>4&0xf))&0xff;
    }else{
	$sum+=($_[0]&0xf0)>>4;
	$sum=($sum+1)&0xff if $sum>0xff;
	$sum=($sum+($_[0]&0xf))&0xff;
    }
    $sc++;
    writesum() if $sc%8==0 and $oldwav;
    writesum() if ($sc>=120 and not $oldwav);
}   

sub writesum{
    unless($oldwav){
	$tmp=(($sum & 0x0f)<<4)+(($sum & 0xf0)>>4);
	write1byte($tmp);
	resetsum();
    }else{			# PC-1245/125x
	write1byte($sum);
	resetsum() if $sc>=80;
    }
    return 1;
}

sub resetsum{
    $sum=$sc=0;
}

sub write1byte{
    unless($oldwav){
	print WAV $w0;
	$_[0] & 0x1 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x2 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x4 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x8 and print WAV $w1 or print WAV $w0;
	print WAV $w1,$w0;
	$_[0] & 0x10 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x20 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x40 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x80 and print WAV $w1 or print WAV $w0;
	print WAV $w1,$w1,$w1,$w1,$w1;
    } else {			# PC-1245/125x
	print WAV $w0;
	$_[0] & 0x10 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x20 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x40 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x80 and print WAV $w1 or print WAV $w0;
	print WAV $w1,$w1,$w1,$w1,$w0;
	$_[0] & 0x1 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x2 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x4 and print WAV $w1 or print WAV $w0;
	$_[0] & 0x8 and print WAV $w1 or print WAV $w0;
	print WAV $w1,$w1,$w1,$w1,$w1;
    }
}
