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

	# ����ե����뤬·�äƤ��뤫��ǧ
	if (
		   ! -e "$self->{ini_file}"
		|| ! -e "./config/hinshi_chasen"
	){
		# ·�äƤ��ʤ��������������
		print "Resetting parameters...\n";
		mkdir "config";
		open (CON,">$self->{ini_file}") or 
			gui_errormsg->open(
				type    => 'file',
				thefile => "m: $self->{ini_file}"
			);
		close (CON);
		# �ʻ�����ե���������
		use DBI;
		use DBD::CSV;
		my $dbh = DBI->connect("DBI:CSV:f_dir=./config") or die;
		$dbh->do(
			"CREATE TABLE hinshi_chasen (
				hinshi_id INTEGER,
				kh_hinshi CHAR(225),
				condition1 CHAR(225),
				condition2 CHAR(225)
			)"
		) or die;
		my @table = (
				"7, '��̾', '̾��-��ͭ̾��-�ϰ�', undef ",
				"6, '��̾', '̾��-��ͭ̾��-��̾', undef ",
				"5,'�ȿ�̾','̾��-��ͭ̾��-�ȿ�',undef",
				"'4','��ͭ̾��','̾��-��ͭ̾��',undef",
				"'2','����̾��','̾��-������³',undef",
				"'3','����ư��','̾��-����ư��촴',undef",
				"'8','�ʥ�����','̾��-�ʥ����ƻ�촴',undef",
				"'16','̾��B','̾��-����','�Ҥ餬��'",
				"'16','̾��B','̾��-�����ǽ','�Ҥ餬��',",
				"'20','̾��C','̾��-����','��ʸ��'",
				"'20','̾��C','̾��-�����ǽ','��ʸ��'",
				"'1','̾��','̾��-����',undef",
				"'1','̾��','̾��-�����ǽ',undef",
				"'9','ʣ��̾��','ʣ��̾��',undef",
				"'10','̤�θ�','̤�θ�',undef",
				"'12','��ư��','��ư��',undef",
				"'12','��ư��','�ե��顼',undef",
				"'11','����','����',undef",
				"'17','ư��B','ư��-��Ω','�Ҥ餬��'",
				"'13','ư��','ư��-��Ω',undef",
				"'18','���ƻ�B','���ƻ�','�Ҥ餬��'",
				"'14','���ƻ�','���ƻ�',undef",
				"'19','����B','����','�Ҥ餬��'",
				"'15','����','����',undef"
		);
		foreach my $i (@table){
			$dbh->do("
				INSERT INTO hinshi_chasen
					(hinshi_id, kh_hinshi, condition1, condition2 )
				VALUES
					( $i )
			") or die($i);
		}

		$dbh->disconnect;
	}


	# ini�ե�����
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


	bless $self, $class;

	$self = $self->_readin;


	return $self;
}
#--------------------#
#   �����ǲ��ϴط�   #

sub refine_cj{
	my $self = shift;
	bless $self, 'kh_sysconfig::win32::'.$self->c_or_j;
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


#-------------#
#   GUI�ط�   #

sub DocSrch_CutLength{
	my $self = shift;
	if (defined($self->{DocSrch_CutLength})){
		return $self->{DocSrch_CutLength};
	} else {
		return '66';
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
		$i = "blue";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		return @h;
	}
}

sub color_DocView_search{
	my $self = shift;
	my $i    = $self->{color_DocView_search};
	unless ( defined($i) ){
		$i = "on_yellow";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		return @h;
	}
}

sub color_DocView_force{
	my $self = shift;
	my $i    = $self->{color_DocView_force};
	unless ( defined($i) ){
		$i = "on_cyan";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		return @h;
	}
}

sub color_DocView_html{
	my $self = shift;
	my $i    = $self->{color_DocView_html};
	unless ( defined($i) ){
		$i = "red";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
		return @h;
	}
}

sub color_DocView_CodeW{
	my $self = shift;
	my $i    = $self->{color_DocView_CodeW};
	unless ( defined($i) ){
		$i = "blue,underline";
	}
	if ($_[1]){
		return $i;
	} else {
		my @h = split /,/, $i;
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




#------------#
#   ����¾   #

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


1;
