package gui_window::morpho_crossout::csv;
use base qw(gui_window::morpho_crossout);

use strict;

#----------#
#   �¹�   #

sub save{
	my $self = shift;
	
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}
	
	# ��¸��λ���
	my @types = (
		[ Jcode->new('CSV Files')->sjis,[qw/.csv/] ],
		#[ Jcode->new('���ֶ��ڤ�')->sjis,[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('��ʸ�����и��ɽ��̾�����դ�����¸')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	unless ($path){
		return 0;
	}
	
	my $ans = $self->win_obj->messageBox(
		-message => Jcode->new
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�����Ǥ�����"
			)->sjis,
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ($ans =~ /ok/i){ return 0; }
	
	my $w = gui_wait->start;
	mysql_crossout::csv->new(
		tani   => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		file   => $path,
	)->run;
	$w->end;
	
	$self->close;
}

#--------------#
#   ��������   #


sub label{
	return '��ʸ�����и��ɽ�ν��ϡ� CSV';
}

sub win_name{
	return 'w_morpho_crossout_CSV';
}

1;
