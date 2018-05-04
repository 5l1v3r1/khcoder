package mysql_contxt::csv;
use base qw(mysql_contxt);
use strict;

#---------------------#
#   1���ܤ��դ�­��   #

sub _save_finish{
	my $self = shift;
	
	use kh_csv;
	my $first_line = '��и�,';
	foreach my $w2 (@{$self->{wList2}}){
		$first_line .= 'cw: '.kh_csv->value_conv($self->{wName2}{$w2}).',';
	}
	chop $first_line;
	$first_line = Jcode->new($first_line)->sjis;
	
	my $file = $self->data_file;
	my $file_tmp = "$file".".bak";
	
	open (OLD,"$file") or 
		gui_errormsg->open(
			type    => 'file',
			thefile => "$file",
		);
	open (NEW,">$file_tmp") or
		gui_errormsg->open(
			type    => 'file',
			thefile => "$file_tmp",
		);
	print NEW "$first_line\n";
	while (<OLD>){
		print NEW $_;
	}
	close (NEW);
	close (OLD);
	unlink($file);
	rename($file_tmp,$file);

	unless ($::config_obj->os eq 'win32'){
		kh_jchar->to_euc($file);
	}
}

#--------------#
#   ��������   #
#--------------#

sub data_file{
	my $self = shift;
	return $self->{file_save};
}


1;