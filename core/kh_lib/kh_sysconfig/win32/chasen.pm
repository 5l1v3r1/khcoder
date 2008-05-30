package kh_sysconfig::win32::chasen;
use strict;
use base qw(kh_sysconfig::win32);
use gui_errormsg;

sub config_morph{
	my $self = shift;
	my $pos = rindex($self->{chasen_path},'\\');
	$self->{grammercha} = substr($self->{chasen_path},0,$pos);
	$self->{chasenrc} = "$self->{grammercha}".'\\dic\chasenrc';
	$self->{dic_dir} =  "$self->{grammercha}".'\\dic';
	$self->{grammercha} .= '\dic\grammar.cha';
	
	$self->{dic_dir} = Jcode->new($self->{dic_dir},'sjis')->euc;
	$self->{dic_dir} =~ s/\\/\//g;
	#print "$self->{dic_dir}\n";
	
	# Grammer.cha�ե�������ѹ�
	
	# �ɤ߹���
	my $grammercha = $self->{grammercha};
	my $temp = ''; my $khflg = 0;
	open (GRA,"$grammercha") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => $grammercha
		);
	while (<GRA>){
		chomp;
		if ($_ eq '; by KH Coder, start.'){
			$khflg = 1;
			next;
		}
		elsif ($_ eq '; by KH Coder, end.'){
			$khflg = 0;
			next;
		}
		if ($khflg){
			next;
		} else {
			$temp .= "$_\n";
		}
	}
	close (GRA);
	
	# �Խ�
	my $temp2 = '(ʣ��̾��)'."\n".'(����)'."\n";
	Jcode::convert(\$temp2,'sjis','euc');
	$temp .= '; by KH Coder, start.'."\n"."$temp2".'; by KH Coder, end.';
	
	# �񤭽Ф�
	my $temp_file = 'temp.txt';
	while (-e $temp_file){
		$temp_file .= '.tmp';
	}
	open (GRAO,">$temp_file") or
		gui_errormsg->open(
			type    => 'file',
			thefile => $temp_file
		);
	print GRAO "$temp";
	close (GRAO);
	
	unlink $grammercha;
	rename ("$temp_file","$grammercha");
	
	my $chasenrc = $self->{chasenrc};
	
	
	# chasen.rc�ե�������ѹ�
	
	# �ɤ߹���
	$temp = ''; $khflg = 0;
	open (GRA,"$chasenrc") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$chasenrc"
		);
	while (<GRA>){
		chomp;
		if ($_ eq '; by KH Coder, start.'){
			$khflg = 1;
			next;
		}
		elsif ($_ eq '; by KH Coder, end.'){
			$khflg = 0;
			next;
		}
		if ($khflg){
			next;
		} else {
			$temp .= "$_\n";
		}
	}
	close (GRA);
	
	# �Խ�
	$temp2  = "(ʸˡ�ե�����  \"$self->{dic_dir}\")\n";
	$temp2 .= '(��� (("<" ">") (����)) )'."\n";
	if ($self->{use_hukugo}){
		$temp2 .= '(Ϣ���ʻ�'."\n";
		$temp2 .= "\t".'((ʣ��̾��)'."\n";
		$temp2 .= "\t\t".'(̾��)'."\n";
		$temp2 .= "\t\t".'(��Ƭ��̾����³)'."\n";
		$temp2 .= "\t\t".'(��Ƭ�����³)'."\n";
		$temp2 .= "\t\t".'(���� ����)'."\n";
		$temp2 .= "\t".')'."\n";
		$temp2 .= ')'."\n";
	}
	Jcode::convert(\$temp2,'sjis','euc');
	$temp .= '; by KH Coder, start.'."\n"."$temp2".'; by KH Coder, end.';

	# �񤭽Ф�
	$temp_file = 'temp.txt';
	while (-e $temp_file){
		$temp_file .= '.tmp';
	}
	open (GRAO,">$temp_file") or
		gui_errormsg->open(
			type    => 'file',
			thefile => $temp_file
		);
	print GRAO "$temp";
	close (GRAO);
	unlink $chasenrc;
	rename ("$temp_file","$chasenrc");
}

sub path_check{
	if ($::config_obj->os ne 'win32'){
		return 1;
	}

	my $self = shift;
	my $path = $self->chasen_path;

	if (not (-e $path) or not ($path =~ /chasen\.exe\Z/i) ){
		gui_errormsg->open(
			type   => 'msg',
			window => \$gui_sysconfig::inis,
			msg    => "Chasen.exe�Υѥ��������Ǥ�"
		);
		return 0;
	}
	return 1;
}


1;
__END__

1;
