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
		[ $self->gui_jchar('���ֶ��ڤ�'),[qw/.txt/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.txt',
		-filetypes        => \@types,
		-title            =>
			$self->gui_jt('��ʸ�����и��ɽ��̾�����դ�����¸'),
		-initialdir       => $self->gui_jchar($::config_obj->cwd),
	);
	unless ($path){
		return 0;
	}
	$path = gui_window->gui_jg_filename_win98($path);
	$path = gui_window->gui_jg($path);
	$path = $::config_obj->os_path($path);
	
	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�����Ǥ�����"
			),
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
		max_df => $self->max_df,
		min_df => $self->min_df,
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
