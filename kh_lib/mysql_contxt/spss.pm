package mysql_contxt::spss;
use base qw(mysql_contxt);
use strict;

#--------------------------------#
#   ���󥿥å����ե�����ν���   #

sub _save_finish{
	my $self = shift;
	my $file_data   = $self->data_file;
	my $file_syntax = $self->synt_file;
	
	# �ѿ����
	my $spss;
	$spss .= "file handle trgt1 /name=\'";
	if ($::config_obj->os eq 'win32'){
		$spss .= Jcode->new($file_data,'sjis')->euc;
	} else {
		$spss .= $file_data;
	}
	$spss .= "\'\n";
	$spss .= "                 /lrecl=32767 .\n";
	$spss .= "data list list(',') file=trgt1 /\n";
	$spss .= "  word(A255)\n";
	my $n = 0;
	foreach my $w2 (@{$self->{wList2}}){
		$spss .= "  cw$n(F10.8)\n";
		++$n;
	}
	$spss .= ".\nexecute.\n";

	# �ѿ���٥�
	$n = 0;
	$spss .= "variable labels\n";
	$spss .= "  word \'��и�\'\n";
	foreach my $w2 (@{$self->{wList2}}){
		$spss .= "  cw$n \'cw: $self->{wName2}{$w2}\'\n";
		++$n;
	}
	$spss .= ".\nexecute.";

	open (SOUT,">$file_syntax") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$file_syntax",
		);
	print SOUT $spss;
	close (SOUT);
	kh_jchar->to_sjis($file_syntax);
}


#--------------#
#   ��������   #
#--------------#

sub data_file{
	my $self = shift;
	return substr($self->{file_save},0,length($self->{file_save})-4).".dat";
}
sub synt_file{
	my $self = shift;
	return $self->{file_save};
}
1;