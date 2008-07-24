package kh_morpho::win32::chasen;
# use strict;
use base qw( kh_morpho::win32 );

#--------------------#
#   ��䥤μ¹Դط�   #
#--------------------#

sub _run_morpho{
	my $self = shift;	
	my $path = $self->config->chasen_path;
	
	my $pos = rindex($path,"\\");
	$self->{dir} = substr($path,0,$pos);
	my $chasenrc = $self->{dir}."\\dic\\chasenrc";
	$self->{cmdline} = "chasen -r \"$chasenrc\" -o \"".$self->output."\" \"".$self->target."\"";
	
	require Win32;
	require Win32::Process;
	my $ChasenObj;
	Win32::Process::Create(
		$ChasenObj,
		$path,
		$self->{cmdline},
		0,
		CREATE_NO_WINDOW,
		$self->{dir},
	) || $self->Exec_Error("Wi32::Process can not start");
	$ChasenObj->Wait(INFINITE)
		|| $self->Exec_Error("Wi32::Process can not wait");
	
	return(1);
}

sub exec_error_mes{
	return "KH Coder Error!!\n��䥤ε�ư�˼��Ԥ��ޤ�����";
}


1;
