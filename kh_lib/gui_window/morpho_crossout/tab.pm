package gui_window::morpho_crossout::tab;
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
		[ Jcode->new('���ֶ��ڤ�')->sjis,[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
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
	mysql_crossout::tab->new(
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
	return '��ʸ�����и��ɽ�ν��ϡ� ���ֶ��ڤ�';
}

sub win_name{
	return 'w_morpho_crossout_tab';
}

1;
