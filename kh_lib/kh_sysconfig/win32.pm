package kh_sysconfig::win32;
use base qw(kh_sysconfig);
use strict;

#------------------#
#   ����ν����   #
#------------------#
sub reset_parm{
		my $self = shift;
		print "Resetting parameters...\n";
		mkdir "config";
		unless (-e $self->{ini_file}){
			open (CON,">$self->{ini_file}") or 
				gui_errormsg->open(
					type    => 'file',
					thefile => "m: $self->{ini_file}"
				);
			close (CON);
		}
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
				"7, '��̾', '̾��-��ͭ̾��-�ϰ�', undef",
				"6, '��̾', '̾��-��ͭ̾��-��̾', undef",
				"5,'�ȿ�̾','̾��-��ͭ̾��-�ȿ�', undef",
				"'4','��ͭ̾��','̾��-��ͭ̾��', undef",
				"'2','����̾��','̾��-������³', undef",
				"'3','����ư��','̾��-����ư��촴', undef",
				"'8','�ʥ�����','̾��-�ʥ����ƻ�촴', undef",
				"'16','̾��B','̾��-����','�Ҥ餬��'",
				#"'16','̾��B','̾��-�����ǽ','�Ҥ餬��'",
				"'20','̾��C','̾��-����','��ʸ��'",
				#"'20','̾��C','̾��-�����ǽ','��ʸ��'",
				"'21','�����ư��','��ư��','����'",
				"'1','̾��','̾��-����', undef",
				"'9','�����ǽ','̾��-�����ǽ', undef",
				"'10','̤�θ�','̤�θ�', undef",
				"'12','��ư��','��ư��', undef",
				"'12','��ư��','�ե��顼', undef",
				"'99999','HTML����','����', 'HTML'",
				"'11','����','����', undef",
				"'17','ư��B','ư��-��Ω','�Ҥ餬��'",
				"'13','ư��','ư��-��Ω', undef",
				"'22','���ƻ����Ω��','���ƻ�-��Ω', undef",
				"'18','���ƻ�B','���ƻ�','�Ҥ餬��'",
				"'14','���ƻ�','���ƻ�', undef",
				"'19','����B','����','�Ҥ餬��'",
				"'15','����','����', undef"
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

#----------------------------#
#   ������ɤ߹��ߥ롼����   #
#----------------------------#

sub _readin{
	use Jcode;
	use kh_sysconfig::win32::chasen;
	use kh_sysconfig::win32::juman;

	my $self = shift;

	# Chasen������
	if (-e $self->{chasen_path}){
		my $pos = rindex($self->{chasen_path},'\\');
		$self->{grammercha} = substr($self->{chasen_path},0,$pos);
		$self->{chasenrc} = "$self->{grammercha}".'\\dic\chasenrc';
		$self->{grammercha} .= '\dic\grammar.cha';
		
		my $flag = 0; my $msg = '(Ϣ���ʻ�';
		Jcode::convert(\$msg,'sjis','euc');
		if (-e $self->{chasenrc}){
			open (CRC,"$self->{chasenrc}") or
				gui_errormsg->open(
					type    => 'file',
					thefile => "$self->{chasenrc}"
				);
			while (<CRC>){
				chomp;
				if ($_ eq '; by KH Coder, start.'){
					$flag = 1;
					next;
				}
				elsif ($_ eq '; by KH Coder, end.'){
					$flag = 0;
					next;
				}

				unless ($flag){
					next;
				}
				if ($_ eq "$msg"){
					$self->{use_hukugo} = 1;
				}
			}
			close (CRC);
		}
		unless ($self->{use_hukugo}){
			$self->{use_hukugo} = 0;
		}
	}

	return $self;
}

#------------------#
#   �����ͤ���¸   #
#------------------#

sub save{
	my $self = shift;
	$self = $self->refine_cj;
	if ($self->path_check){
		$self->config_morph;
		my @outlist = (
			'chasen_path',
			'juman_path',
			'c_or_j',
			'r_path',
			'sqllog',
			'sql_username',
			'sql_password',
			'sql_host',
			'sql_port',
			'mail_if',
			'mail_smtp',
			'mail_from',
			'mail_to',
			'use_heap',
			'all_in_one_pack',
			'font_main',
			'kaigyo_kigou',
			'color_DocView_info',
			'color_DocView_search',
			'color_DocView_force',
			'color_DocView_html',
			'color_DocView_CodeW',
			'DocView_WrapLength_on_Win9x',
			'DocSrch_CutLength',
		);
		
		my $f = $self->{ini_file};
		open (INI,">$f") or
			gui_errormsg->open(
				type    => 'file',
				thefile => ">$f"
			);
		foreach my $i (@outlist){
			my $value = $self->$i( undef,'1');
			$value = '' unless defined($value);
			print INI "$i\t".$value."\n";
			# print  "$i\t".$self->$i( undef,'1')."\n";
		}
		foreach my $i (keys %{$self}){
			if ( index($i,'w_') == 0 ){
				my $value = $self->win_gmtry($i);
				$value = '' unless defined($value);
				print INI "$i\t".$value."\n";
			}
		}
		if ($self->{main_window}){
			print INI "main_window\t$self->{main_window}";
		}
		close (INI);
		return 1;
	} else {
		return 0;
	}
}

#--------------------#
#   �����ǲ��ϴط�   #


sub chasen_path{
	my $self = shift;
	my $new = shift;
	if ($new){
		$self->{chasen_path} = $new;
	}
	return $self->{chasen_path};
}

sub juman_path{
	my $self = shift;
	my $new = shift;
	if ($new){
		$self->{juman_path} = $new;
	}
	return $self->{juman_path};
}

#-------------#
#   GUI�ط�   #

sub underline_conv{
	my $self = shift;
	my $n    = shift;
	return $n;
}

sub mw_entry_length{
	return 20;
}

sub font_main{
	my $self = shift;
	my $new  = shift;
	$self->{font_main} = $new         if defined($new) && length($new);
	$self->{font_main} = 'MS UI Gothic,10'  unless length($self->{font_main});
	return $self->{font_main};
}

#------------#
#   ����¾   #


sub os_path{
	my $self  = shift;
	my $c     = shift;
	my $icode = shift;

	#print "kh_sysconfig::win32::os_path[1]:  $c\n";

	$c = Jcode->new("$c",$icode)->euc;
	$c =~ tr/\//\\/;
	$c = Jcode->new("$c",'euc')->sjis;
	
	#print "kh_sysconfig::win32::os_path[2]:  $c\n";
	
	return $c;
}

sub os_cod_path{
	my $self  = shift;
	my $c     = shift;
	my $icode = shift;

	#print "kh_sysconfig::win32::os_path[1]:  $c\n";

	$c = Jcode->new("$c",$icode)->euc;
	$c =~ tr/\//\\/;
	$c = Jcode->new("$c",'euc')->sjis;
	
	$c = Jcode->new("$c",$icode)->euc;
	$c =~ tr/\\/\//;
	$c = Jcode->new("$c",'euc')->sjis;
	
	#print "kh_sysconfig::win32::os_path[2]:  $c\n";
	
	return $c;
}


sub R_device{
	my $self  = shift;
	my $path  = shift;
	my $width = shift;
	my $height = shift;
	$path .= '.bmp';
	
	$width  = 480 unless $width;
	$height = 480 unless $height;

	return 0 unless $::config_obj->R;
	
	$::config_obj->R->send(
		"bmp(\"$path\", width=$width, height=$height, unit=\"px\")"
	);
	return $path;
}


1;

__END__
