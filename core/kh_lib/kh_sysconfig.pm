package kh_sysconfig;
use strict;

use kh_sysconfig::win32;
use kh_sysconfig::linux;

sub readin{
	my $class = shift;
	$class .= '::'.&os;
	my $self;
	$self->{ini_file} = shift;
	$self->{cwd} = shift;
	bless $self, $class;

	# cwd�Υ����å�
	if ( $] > 5.008 ) {
		if ( utf8::is_utf8($self->{cwd}) ){
			warn "Error: Unexpected UTF8 Flag!";
		}
	}
	#print "kh_sysconfig: $self->{cwd}\n";

	# ����ե����뤬·�äƤ��뤫��ǧ
	if (
		   ! -e "$self->{ini_file}"
		|| ! -e "./config/hinshi_chasen"
		|| ! -e "./config/hinshi_mecab"
		|| ! -e "./config/hinshi_stemming"
	){
		# ·�äƤ��ʤ��������������
		$self->reset_parm;
	}

	# ini�ե�����
	#print "kh_sysconfig: $self->{ini_file}\n";
	open (CINI,"$self->{ini_file}") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$self->{ini_file}"
		);
	while (<CINI>){
		chomp;
		my @temp = split /\t/, $_;
		$self->{$temp[0]} = $temp[1];
	}
	close (CINI);

	# ����¾
	$self->{history_file} = $self->{cwd}.'/config/projects';
	$self->{history_trush_file} = $self->{cwd}.'/config/projects_trush';

	$self = $self->_readin;

	return $self;
}

#------------------#
#   ����ν����   #

sub reset_parm{
		my $self = shift;
		print "Resetting parameters...\n";
		mkdir 'config' unless -d 'config';
		
		# ����ե�����ν���
		unless (-e $self->{ini_file}){
			open (CON,">$self->{ini_file}") or 
				gui_errormsg->open(
					type    => 'file',
					thefile => "m: $self->{ini_file}"
				);
			close (CON);
		}
		
		# �ʻ�����ե�����κ�������
		use DBI;
		use DBD::CSV;
		my $dbh = DBI->connect("DBI:CSV:f_dir=./config") or die;
		my @table = (
				"'7', '��̾', '̾��-��ͭ̾��-�ϰ�', ''",
				"'6', '��̾', '̾��-��ͭ̾��-��̾', ''",
				"'5','�ȿ�̾','̾��-��ͭ̾��-�ȿ�', ''",
				"'4','��ͭ̾��','̾��-��ͭ̾��', ''",
				"'2','����̾��','̾��-������³', ''",
				"'3','����ư��','̾��-����ư��촴', ''",
				"'8','�ʥ�����','̾��-�ʥ����ƻ�촴', ''",
				"'16','̾��B','̾��-����','�Ҥ餬��'",
				#"'16','̾��B','̾��-�����ǽ','�Ҥ餬��'",
				"'20','̾��C','̾��-����','��ʸ��'",
				#"'20','̾��C','̾��-�����ǽ','��ʸ��'",
				"'21','�����ư��','��ư��','����'",
				"'1','̾��','̾��-����', ''",
				"'9','�����ǽ','̾��-�����ǽ', ''",
				"'10','̤�θ�','̤�θ�', ''",
				"'12','��ư��','��ư��', ''",
				"'12','��ư��','�ե��顼', ''",
				"'99999','HTML����','����', 'HTML'",
				"'11','����','����', ''",
				"'17','ư��B','ư��-��Ω','�Ҥ餬��'",
				"'13','ư��','ư��-��Ω', ''",
				"'22','���ƻ����Ω��','���ƻ�-��Ω', ''",
				"'18','���ƻ�B','���ƻ�','�Ҥ餬��'",
				"'14','���ƻ�','���ƻ�', ''",
				"'19','����B','����','�Ҥ餬��'",
				"'15','����','����', ''"
		);
		
		# �����
		unless (-e "./config/hinshi_chasen"){
			$dbh->do(
				"CREATE TABLE hinshi_chasen (
					hinshi_id INTEGER,
					kh_hinshi CHAR(225),
					condition1 CHAR(225),
					condition2 CHAR(225)
				)"
			) or die;
			foreach my $i (@table){
				$dbh->do("
					INSERT INTO hinshi_chasen
						(hinshi_id, kh_hinshi, condition1, condition2 )
					VALUES
						( $i )
				") or die($i);
			}
		}

		# MeCab��
		unless (-e "./config/hinshi_mecab"){
			$dbh->do(
				"CREATE TABLE hinshi_mecab (
					hinshi_id INTEGER,
					kh_hinshi CHAR(225),
					condition1 CHAR(225),
					condition2 CHAR(225)
				)"
			) or die;
			foreach my $i (@table){
				$dbh->do("
					INSERT INTO hinshi_mecab
						(hinshi_id, kh_hinshi, condition1, condition2 )
					VALUES
						( $i )
				") or die($i);
			}
		}

		# Stemming��
		unless (-e "./config/hinshi_stemming"){
			$dbh->do(
				"CREATE TABLE hinshi_stemming (
					hinshi_id INTEGER,
					kh_hinshi CHAR(225),
					condition1 CHAR(225),
					condition2 CHAR(225)
				)"
			) or die;
			$dbh->do("
				INSERT INTO hinshi_stemming
					(hinshi_id, kh_hinshi, condition1, condition2 )
				VALUES
					( 1, 'ALL', 'ALL', '' ),
					(99999,'HTML����','����','HTML'),
					(11,'����','����','')
			") or die();
		}

		$dbh->disconnect;
}

#------------------#
#   Temp�ե�����   #

sub file_temp{
	my $n = 0;
	while (-e '.khc'.$n.'.tmp'){
		++$n;
	}
	return '.khc'.$n.'.tmp';
}

#--------------------#
#   �����ǲ��ϴط�   #

sub refine_cj{
	my $self = shift;
	bless $self, 'kh_sysconfig::'.$self->os.'::'.$self->c_or_j;
	return $self;
}

sub use_hukugo{
	my $self = shift;
	my $new = shift;
	if (length($new) > 0){
		$self->{use_hukugo} = $new;
	}
	return $self->{use_hukugo};
}

sub c_or_j{
	my $self = shift;
	my $new = shift;
	if ($new){
		$self->{c_or_j} = $new;
	}

	if (length($self->{c_or_j}) > 0) {
		return $self->{c_or_j};
	} else {
		return 'chasen';
	}
}

sub stemming_lang{
	my $self = shift;
	my $new = shift;
	if ($new){
		$self->{stemming_lang} = $new;
	}

	if (length($self->{stemming_lang}) > 0) {
		return $self->{stemming_lang};
	} else {
		return 'en';
	}
}

sub msg_lang{
	my $self = shift;
	my $new = shift;
	if ($new){
		$self->{msg_lang} = $new;
	}

	if (length($self->{msg_lang}) > 0) {
		return $self->{msg_lang};
	} else {
		return 'jp';
	}
}

sub stopwords{
	my $self = shift;
	my %args = @_;

	unless ( length($args{locale}) ){
		$args{locale} = 'd';
	}

	my $type = $args{method}.'_'.$args{locale};

	if ( defined( $args{stopwords} ) ){
		# �ǡ�����¸
		my $dbh = DBI->connect("DBI:CSV:f_dir=./config") or die;
		if (-e "./config/stopwords_$type"){
			$dbh->do("
				DROP TABLE stopwords_$type
			") or die;
		}
		
		$dbh->do("
			CREATE TABLE stopwords_$type (name CHAR(225))
		") or die;
		
		my $sth = $dbh->prepare(
			"INSERT INTO stopwords_$type (name) VALUES (?)"
		) or die;
		
		foreach my $i (@{$args{stopwords}}){
			$sth->execute($i);
		}
		
		$dbh->disconnect;
		return $args{stopwords};
	} else {
		# �ǡ����ɤ߽Ф�
		my @words = ();
		my $dbh = DBI->connect("DBI:CSV:f_dir=./config") or die;
		if (-e "./config/stopwords_$type"){
			my $sth = $dbh->prepare("
				SELECT name FROM stopwords_$type
			") or die;
			$sth->execute;
			while (my $i = $sth->fetch){
				push @words, $i->[0];
			}
		}
		$dbh->disconnect;
		return \@words;
	}
}

sub stopwords_current{
	my $self = shift;

	my $type = $self->c_or_j;
	
	if ($self->c_or_j eq 'stemming'){
		$type .= '_'.$self->stemming_lang;
	} else {
		$type .= '_d';
	}
	
	my @words = ();
	my $dbh = DBI->connect("DBI:CSV:f_dir=./config") or die;
	if (-e "./config/stopwords_$type"){
		my $sth = $dbh->prepare("
			SELECT name FROM stopwords_$type
		") or die;
		$sth->execute;
		while (my $i = $sth->fetch){
			push @words, $i->[0];
		}
	}
	$dbh->disconnect;
	return \@words;
}

sub use_sonota{
	my $self = shift;
	my $new = shift;
	if ( length($new) > 0 ){
		$self->{use_sonota} = $new;
	}

	if ( $self->{use_sonota} ){
		return $self->{use_sonota};
	} else {
		return 0;
	}
}

sub hukugo_chasenrc{
	my $self = shift;
	my $new = shift;
	
	if ( defined($new) ){
		$self->{hukugo_chasenrc} = $new;
	}
	
	if ( length($self->{hukugo_chasenrc}) ){
		return $self->{hukugo_chasenrc};
	} else {
		my $t = '';
		$t .= '(Ϣ���ʻ�'."\n";
		$t .= "\t".'((ʣ��̾��)'."\n";
		$t .= "\t\t".'(̾��)'."\n";
		$t .= "\t\t".'(��Ƭ�� ̾����³)'."\n";
		$t .= "\t\t".'(��Ƭ�� ����³)'."\n";
		$t .= "\t\t".'(���� ����)'."\n";
		$t .= "\t".')'."\n";
		$t .= ')'."\n";
		return $t;
	}
}


#-------------#
#   GUI�ط�   #

# Window���֤ȥ������Υꥻ�å�
sub ClearGeometries{
	my $self = shift;
	foreach my $i (keys %{$self}){
		undef $self->{$i} if $i =~ /^w_/;
	}
	return $self;
}

sub DocSrch_CutLength{
	my $self = shift;
	if (defined($self->{DocSrch_CutLength})){
		return $self->{DocSrch_CutLength};
	} else {
		return '85';
	}
}

sub DocView_WrapLength_on_Win9x{
	my $self = shift;
	if (defined($self->{DocView_WrapLength_on_Win9x})){
		return $self->{DocView_WrapLength_on_Win9x};
	} else {
		return '80';
	}
}

sub color_DocView_info{
	my $self = shift;
	my $i    = $self->{color_DocView_info};
	unless ( defined($i) ){
		$i = "#008000,white,0";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		$h[2] = 0 unless defined($h[2]) && length($h[2]);
		return @h;
	}
}

sub color_ListHL_fore{
	my $self = shift;
	
	
	if( defined( $self->{color_ListHL_fore} ) ){
		return $self->{color_ListHL_fore};
	} else {
		return 'black';
	}
}

sub color_ListHL_back{
	my $self = shift;
	
	
	if( defined( $self->{color_ListHL_back} ) ){
		return $self->{color_ListHL_back};
	} else {
		return '#AFEEEE';
	}
}


sub color_DocView_search{
	my $self = shift;
	my $i    = $self->{color_DocView_search};
	unless ( defined($i) ){
		$i = "black,yellow,0";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		$h[2] = 0 unless defined($h[2]) && length($h[2]);
		return @h;
	}
}

sub color_DocView_force{
	my $self = shift;
	my $i    = $self->{color_DocView_force};
	unless ( defined($i) ){
		$i = "black,cyan,0";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		$h[2] = 0 unless defined($h[2]) && length($h[2]);
		return @h;
	}
}

sub color_DocView_html{
	my $self = shift;
	my $i    = $self->{color_DocView_html};
	unless ( defined($i) ){
		$i = "red,white,0";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		$h[2] = 0 unless defined($h[2]) && length($h[2]);
		return @h;
	}
}

sub color_DocView_CodeW{
	my $self = shift;
	my $i    = $self->{color_DocView_CodeW};
	unless ( defined($i) ){
		$i = "blue,white,1";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		$h[2] = 0 unless length($h[2]);
		return @h;
	}
}

sub win_gmtry{
	my $self = shift;
	my $win_name = shift;
	my $geometry = shift;
	if (defined($geometry)){
		$self->{$win_name} = $geometry;
	} else {
		return $self->{$win_name};
	}
}

#---------------#
#   MySQL��Ϣ   #
#---------------#

sub sql_username{
	my $self = shift;
	my $new  = shift;
	
	if (defined($new) && length($new)){
		$self->{sql_username} = $new;
	}
	return $self->{sql_username};
}

sub sql_password{
	my $self = shift;
	my $new  = shift;
	
	if (defined($new) && length($new)){
		$self->{sql_password} = $new;
	}
	return $self->{sql_password};
}

sub sql_port{
	my $self = shift;
	my $new  = shift;
	
	if (defined($new) && length($new)){
		$self->{sql_port} = $new;
	}
	return $self->{sql_port};
}

sub sql_host{
	my $self = shift;
	my $new  = shift;
	
	if (defined($new) && length($new)){
		$self->{sql_host} = $new;
	}
	if ( defined($self->{sql_host}) ){
		return $self->{sql_host};
	} else {
		return 'localhost';
	}
}

sub sqllog{
	my $self = shift;
	my $new = shift;
	
	if ( defined($new) && length($new) ){
		$self->{sqllog} = $new;
	}

	return $self->{sqllog};
}

sub sqllog_file{
	my $self = shift;
	return "./config/sql.log";
}

#------------#
#   ����¾   #

sub all_in_one_pack{
	my $self = shift;
	return $self->{all_in_one_pack};
}

sub kaigyo_kigou{
	my $self = shift;
	my $new  = shift;
	
	# �������ͤ���ꤵ�줿���
	if (defined($new)){
		$self->{kaigyo_kigou} = $new;
	}
	
	# �ǥե������
	unless ($self->{kaigyo_kigou}){
		return '�ʢ���';
	}
	
	return $self->{kaigyo_kigou};
}

sub R{
	my $self = shift;
	return $self->{R};
}

sub R_version{
	my $self = shift;
	
	if ( $self->{R} ){
		if ( $self->{R_version} ){
			return $self->{R_version};
		} else {
			$::config_obj->R->send(
				'print( paste("khcoder", R.Version()$major, R.Version()$minor , sep="") )'
			);
			my $v1 = $::config_obj->R->read;
			if ($v1 =~ /"khcoder(.+)"/){
				$v1 = $1;
			} else {
				warn "could not get Version Number of R...\n";
				return 0;
			}
			
			if ($v1 =~ /([0-9])([0-9]+)\./){
				print "R Version: $1.$2\n";
				$self->{R_version} = $1 * 100 + $2;
				return $self->{R_version};
			} else {
				warn "could not get Version Number of R...\n";
				return 0;
			}
		}
	} else {
		return 0;
	}
}

sub multi_threads{
	my $self = shift;
	my $new = shift;
	if ( defined($new) ){
		$self->{multi_threads} = $new;
	}
	
	if ( length($self->{multi_threads}) ){
		return $self->{multi_threads};
	} else {
		return 0;
	}
}

sub r_plot_debug{
	my $self = shift;
	my $new = shift;
	if ( defined($new) ){
		$self->{r_plot_debug} = $new;
	}
	
	if ( length($self->{r_plot_debug}) ){
		return $self->{r_plot_debug};
	} else {
		return 0;
	}
}

sub r_path{
	my $self = shift;
	my $new = shift;
	if ( length($new) && -e $new ){
		$self->{r_path} = $new;
	}
	return $self->{r_path};
}

sub r_dir{
	my $self = shift;
	if ( -e $self->{r_path} ) {
		if ( $self->{r_path} =~ /\A(.+)Rterm\.exe/i){
			my $v = $1;
			chop $v;
			chop $v;
			chop $v;
			chop $v;
			chop $v;
			return $v;
		}
	}
}

sub r_default_font_size{
	my $self = shift;
	
	if ($self->R_version > 210){
		return 100;
	} else {
		return 80;
	}
}

sub in_preprocessing{
	my $self = shift;
	my $new = shift;
	if ( length($new) ){
		$self->{in_preprocessing} = $new;
	}
	return $self->{in_preprocessing};
}

sub use_heap {
	my $self = shift;
	my $new = shift;
	
	if ( defined($new) && length($new) ){                     # �������ͤλ���
		$self->{use_heap} = $new;
	}
	unless (defined($self->{use_heap})){     # �ǥե������
		$self->{use_heap} = 1;
	}
	return $self->{use_heap};
}

sub mail_if{
	my $self = shift;
	my $new = shift;
	if ( defined($new) && length($new) ){
		$self->{mail_if} = $new;
	}
	return $self->{mail_if};
}

sub mail_smtp{
	my $self = shift;
	my $new = shift;
	if ( defined($new) ){
		$self->{mail_smtp} = $new;
	}
	return $self->{mail_smtp};
}

sub mail_from{
	my $self = shift;
	my $new = shift;
	if ( defined($new) ){
		$self->{mail_from} = $new;
	}
	return $self->{mail_from};
}

sub mail_to{
	my $self = shift;
	my $new = shift;
	if ( defined($new) ){
		$self->{mail_to} = $new;
	}
	return $self->{mail_to};
}

sub history_file{
	my $self = shift;
	return $self->{history_file};
}

sub history_trush_file{
	my $self = shift;
	return $self->{history_trush_file};
}

sub cwd{
	my $self = shift;
	my $c = $self->{cwd};
	$c = $self->os_path($c);
	return $c;
}


sub icon_image_file{
	return Tk->findINC('ghome.gif');
}

sub logo_image_file{
	my $self = shift;
	return Tk->findINC('kh_logo.bmp');
}


sub os{
	if ($^O eq 'MSWin32') {
		return 'win32';
	} else {
		return 'linux';
	}
}

sub file_temp{
	my $n = 0;
	while (-e "temp$n.txt"){
		++$n;
	}
	open   (KH_SYSCNF_TEMP, ">temp$n.txt");
	close  (KH_SYSCNF_TEMP);
	return ("temp$n.txt");
}


1;
