package kh_morpho::linux::chasen;
use strict;
use base qw( kh_morpho::linux );

#--------------------#
#   ��䥤μ¹Դط�   #
#--------------------#

sub _run_morpho{
	my $self = shift;

	my $cmdline = "chasen -r ".$::config_obj->chasenrc_path." -o ".$self->output." ".$self->target;
	#print "$cmdline\n";
	system "$cmdline";

	return(1);
}

sub exec_error_mes{
	return "KH Coder Error!!\n��䥤ε�ư�˼��Ԥ��ޤ�����";
}


1;
